-- Migrasi khusus fitur Auto-Transfer & Pembayaran Rutin (Budgeting Plan)
-- Jalankan di Supabase SQL Editor.

BEGIN;

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

-- Index sinkronisasi
CREATE INDEX IF NOT EXISTS auto_schedules_user_updated_idx
  ON public.auto_schedules (user_id, updated_at);

-- Trigger auto-update updated_at
DROP TRIGGER IF EXISTS auto_schedules_set_updated_at ON public.auto_schedules;
CREATE TRIGGER auto_schedules_set_updated_at
  BEFORE UPDATE ON public.auto_schedules
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Row Level Security (RLS)
ALTER TABLE public.auto_schedules ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS auto_schedules_owner_all ON public.auto_schedules;
CREATE POLICY auto_schedules_owner_all ON public.auto_schedules
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

COMMIT;
