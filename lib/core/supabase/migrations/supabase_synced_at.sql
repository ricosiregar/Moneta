-- Moneta: kolom synced_at yang diisi SERVER (bebas selisih jam perangkat).
-- Jalankan di Supabase SQL Editor. Aman dijalankan ulang (idempotent).
--
-- Setelah ini, ubah klien (sync_service.dart) agar cursor pull memakai
-- `synced_at` alih-alih `updated_at`, lalu hapus overlap 2 menit bila mau.

create or replace function public.set_synced_at()
returns trigger
language plpgsql
as $$
begin
  new.synced_at := now();
  return new;
end;
$$;

do $$
declare
  t text;
  tables text[] := array[
    'auto_schedules', 'budget_limits', 'categories',
    'detected_transactions', 'notification_sources', 'saving_jar_entries',
    'saving_jars', 'transactions', 'transfers', 'user_settings',
    'wallet_allocations', 'wallets'
  ];
begin
  foreach t in array tables loop
    execute format(
      'alter table public.%I add column if not exists synced_at timestamptz not null default now()',
      t);
    execute format(
      'create index if not exists %I on public.%I (synced_at)',
      'idx_' || t || '_synced_at', t);
    execute format('drop trigger if exists trg_set_synced_at on public.%I', t);
    execute format(
      'create trigger trg_set_synced_at before insert or update on public.%I '
      'for each row execute function public.set_synced_at()',
      t);
  end loop;
end $$;

-- Catatan:
-- * Indeks hanya pada synced_at (user_settings memakai user_id, bukan id).
-- * Baris lama otomatis mendapat synced_at = waktu migrasi, sehingga semua
--   perangkat menarik ulang sekali (aman, penerapan idempoten).
