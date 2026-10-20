-- Moneta schema v2 migration (idempotent where practical).
-- Jalankan di Supabase SQL Editor. Setelah selesai, dump ulang schema ke supa.sql.

BEGIN;

-- ─────────────────────────────────────────────────────────────
-- 0. Helper: auto-update updated_at
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- ─────────────────────────────────────────────────────────────
-- 1. Hapus tabel yang tidak dipakai
-- ─────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS public.spending_challenges CASCADE;
DROP TABLE IF EXISTS public.credit_cards CASCADE;
DROP TABLE IF EXISTS public.debts CASCADE;

-- ─────────────────────────────────────────────────────────────
-- 2. Ubah tabel lama
-- ─────────────────────────────────────────────────────────────

-- wallets: hierarki 1 level + metadata
ALTER TABLE public.wallets
  ADD COLUMN IF NOT EXISTS parent_id uuid REFERENCES public.wallets(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS purpose text,
  ADD COLUMN IF NOT EXISTS is_income_source boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS opening_balance numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS sort_order integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS is_archived boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

ALTER TABLE public.wallets
  DROP CONSTRAINT IF EXISTS wallets_not_self_parent;
ALTER TABLE public.wallets
  ADD CONSTRAINT wallets_not_self_parent CHECK (parent_id IS NULL OR parent_id <> id);

-- Maksimal 1 level: induk tidak boleh punya induk, dan induk tidak boleh
-- punya anak bila wallet itu sendiri dijadikan anak.
CREATE OR REPLACE FUNCTION public.wallets_enforce_one_level()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.parent_id IS NOT NULL THEN
    IF EXISTS (SELECT 1 FROM public.wallets WHERE id = NEW.parent_id AND parent_id IS NOT NULL) THEN
      RAISE EXCEPTION 'Wallet induk tidak boleh berupa wallet anak (maks. 1 level)';
    END IF;
    IF EXISTS (SELECT 1 FROM public.wallets WHERE parent_id = NEW.id) THEN
      RAISE EXCEPTION 'Wallet yang punya anak tidak boleh dijadikan anak';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM public.wallets WHERE id = NEW.parent_id AND user_id = NEW.user_id) THEN
      RAISE EXCEPTION 'Wallet induk harus milik user yang sama';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS wallets_one_level ON public.wallets;
CREATE TRIGGER wallets_one_level
  BEFORE INSERT OR UPDATE OF parent_id ON public.wallets
  FOR EACH ROW EXECUTE FUNCTION public.wallets_enforce_one_level();

-- categories
ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

-- transactions: wallet wajib, sumber, link ke deteksi
-- (transaksi lama tanpa wallet dipindah ke wallet "Tunai" milik user itu)
INSERT INTO public.wallets (user_id, name, type)
SELECT DISTINCT t.user_id, 'Tunai', 'cash'
FROM public.transactions t
WHERE t.wallet_id IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM public.wallets w
    WHERE w.user_id = t.user_id AND w.name = 'Tunai'
  );

UPDATE public.transactions t
SET wallet_id = (
  SELECT w.id FROM public.wallets w
  WHERE w.user_id = t.user_id AND w.name = 'Tunai'
  ORDER BY w.created_at LIMIT 1
)
WHERE t.wallet_id IS NULL;

ALTER TABLE public.transactions
  ALTER COLUMN wallet_id SET NOT NULL,
  ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'manual',
  ADD COLUMN IF NOT EXISTS detected_id uuid,
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

ALTER TABLE public.transactions
  DROP CONSTRAINT IF EXISTS transactions_source_check;
ALTER TABLE public.transactions
  ADD CONSTRAINT transactions_source_check
  CHECK (source = ANY (ARRAY['manual', 'notification', 'import']));

-- budget_limits
ALTER TABLE public.budget_limits
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

CREATE UNIQUE INDEX IF NOT EXISTS budget_limits_unique_period
  ON public.budget_limits (user_id, category_id, month, year)
  WHERE deleted_at IS NULL;

-- saving_jars
ALTER TABLE public.saving_jars
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

-- ─────────────────────────────────────────────────────────────
-- 3. Tabel baru
-- ─────────────────────────────────────────────────────────────

-- Pengaturan user (1 baris per user)
CREATE TABLE IF NOT EXISTS public.user_settings (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  default_expense_wallet_id uuid REFERENCES public.wallets(id) ON DELETE SET NULL,
  default_income_wallet_id uuid REFERENCES public.wallets(id) ON DELETE SET NULL,
  currency text NOT NULL DEFAULT 'IDR',
  notification_capture_enabled boolean NOT NULL DEFAULT false,
  last_synced_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Aturan alokasi gaji: sumber -> anak
CREATE TABLE IF NOT EXISTS public.wallet_allocations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  source_wallet_id uuid NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  target_wallet_id uuid NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  label text,
  percent numeric CHECK (percent > 0 AND percent <= 100),
  fixed_amount numeric CHECK (fixed_amount > 0),
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT allocations_distinct_wallets CHECK (source_wallet_id <> target_wallet_id),
  CONSTRAINT allocations_percent_xor_fixed CHECK ((percent IS NULL) <> (fixed_amount IS NULL))
);

-- Transfer antar wallet (bukan income/expense)
CREATE TABLE IF NOT EXISTS public.transfers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  from_wallet_id uuid NOT NULL REFERENCES public.wallets(id),
  to_wallet_id uuid NOT NULL REFERENCES public.wallets(id),
  amount numeric NOT NULL CHECK (amount > 0),
  fee numeric NOT NULL DEFAULT 0 CHECK (fee >= 0),
  date timestamptz NOT NULL DEFAULT now(),
  note text,
  allocation_id uuid REFERENCES public.wallet_allocations(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT transfers_distinct_wallets CHECK (from_wallet_id <> to_wallet_id)
);

-- Pemetaan aplikasi bank (package notifikasi) -> wallet
CREATE TABLE IF NOT EXISTS public.notification_sources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  package_name text NOT NULL,
  wallet_id uuid NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  parser_key text NOT NULL,
  is_enabled boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  UNIQUE (user_id, package_name)
);

-- Inbox transaksi terdeteksi (hasil parsing saja, tanpa teks mentah)
CREATE TABLE IF NOT EXISTS public.detected_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  wallet_id uuid REFERENCES public.wallets(id) ON DELETE SET NULL,
  source_package text,
  amount numeric NOT NULL CHECK (amount > 0),
  type text NOT NULL CHECK (type = ANY (ARRAY['income', 'expense'])),
  merchant text,
  detected_at timestamptz NOT NULL DEFAULT now(),
  fingerprint text NOT NULL,
  status text NOT NULL DEFAULT 'pending'
    CHECK (status = ANY (ARRAY['pending', 'recorded', 'ignored', 'moved'])),
  transaction_id uuid REFERENCES public.transactions(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  UNIQUE (user_id, fingerprint)
);

ALTER TABLE public.transactions
  DROP CONSTRAINT IF EXISTS transactions_detected_id_fkey;
ALTER TABLE public.transactions
  ADD CONSTRAINT transactions_detected_id_fkey
  FOREIGN KEY (detected_id) REFERENCES public.detected_transactions(id) ON DELETE SET NULL;

-- Setoran / penarikan celengan Piggo
CREATE TABLE IF NOT EXISTS public.saving_jar_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  jar_id uuid NOT NULL REFERENCES public.saving_jars(id) ON DELETE CASCADE,
  wallet_id uuid REFERENCES public.wallets(id) ON DELETE SET NULL,
  amount numeric NOT NULL CHECK (amount > 0),
  type text NOT NULL CHECK (type = ANY (ARRAY['deposit', 'withdraw'])),
  date timestamptz NOT NULL DEFAULT now(),
  note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

-- Jadwal otomatis / auto-transfer bulanan (Budgeting Plan)
CREATE TABLE IF NOT EXISTS public.auto_schedules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL,
  kind text NOT NULL DEFAULT 'expense' CHECK (kind = ANY (ARRAY['expense', 'transfer'])),
  amount numeric NOT NULL CHECK (amount > 0),
  day_of_month integer NOT NULL CHECK (day_of_month >= 1 AND day_of_month <= 31),
  wallet_id uuid NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
  to_wallet_id uuid REFERENCES public.wallets(id) ON DELETE SET NULL,
  category_id uuid REFERENCES public.categories(id) ON DELETE SET NULL,
  budget_id uuid REFERENCES public.budget_limits(id) ON DELETE SET NULL,
  note text,
  is_enabled boolean NOT NULL DEFAULT true,
  last_executed_period text,
  last_executed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

-- ─────────────────────────────────────────────────────────────
-- 4. Index sinkronisasi (user_id, updated_at)
-- ─────────────────────────────────────────────────────────────
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'categories','wallets','transactions','budget_limits','auto_schedules','saving_jars',
    'wallet_allocations','transfers','notification_sources',
    'detected_transactions','saving_jar_entries'
  ] LOOP
    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.%I (user_id, updated_at)',
      t || '_user_updated_idx', t);
  END LOOP;
END $$;

CREATE INDEX IF NOT EXISTS wallets_parent_idx ON public.wallets (parent_id);
CREATE INDEX IF NOT EXISTS transactions_wallet_date_idx ON public.transactions (wallet_id, date);
CREATE INDEX IF NOT EXISTS detected_pending_idx
  ON public.detected_transactions (user_id, status) WHERE deleted_at IS NULL;

-- ─────────────────────────────────────────────────────────────
-- 5. Trigger updated_at untuk semua tabel sinkron
-- ─────────────────────────────────────────────────────────────
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'profiles','user_settings','categories','wallets','transactions',
    'budget_limits','auto_schedules','saving_jars','wallet_allocations','transfers',
    'notification_sources','detected_transactions','saving_jar_entries'
  ] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON public.%I', t || '_set_updated_at', t);
    EXECUTE format(
      'CREATE TRIGGER %I BEFORE UPDATE ON public.%I
       FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()',
      t || '_set_updated_at', t);
  END LOOP;
END $$;

-- ─────────────────────────────────────────────────────────────
-- 6. Row Level Security
-- ─────────────────────────────────────────────────────────────
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'wallets','transactions','budget_limits','auto_schedules','saving_jars',
    'wallet_allocations','transfers','notification_sources',
    'detected_transactions','saving_jar_entries','user_settings'
  ] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', t || '_owner_all', t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR ALL TO authenticated
       USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid())',
      t || '_owner_all', t);
  END LOOP;
END $$;

-- categories: kategori bawaan (user_id NULL) boleh dibaca semua user
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS categories_select ON public.categories;
DROP POLICY IF EXISTS categories_write ON public.categories;
CREATE POLICY categories_select ON public.categories FOR SELECT TO authenticated
  USING (user_id IS NULL OR user_id = auth.uid());
CREATE POLICY categories_write ON public.categories FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- profiles: hanya milik sendiri
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS profiles_owner_all ON public.profiles;
CREATE POLICY profiles_owner_all ON public.profiles FOR ALL TO authenticated
  USING (id = auth.uid()) WITH CHECK (id = auth.uid());

COMMIT;
