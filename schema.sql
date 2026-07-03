-- ============================================================
-- AgroTrack Pesquisa · Schema Supabase
-- ============================================================
-- Rode este script inteiro no SQL Editor do seu projeto Supabase.
-- Segue o padrão do CropApp: RLS desabilitado + GRANT explícito
-- para evitar falhas silenciosas (RLS sem policy retorna sucesso
-- com 0 linhas afetadas).
-- ============================================================

-- Tabela principal de demandas
create table if not exists demandas (
  id            uuid primary key default gen_random_uuid(),
  titulo        text not null,
  descricao     text default '',
  responsavel   text not null,            -- login da funcionária atribuída
  prioridade    text not null default 'media',  -- alta | media | baixa
  status        text not null default 'pendente', -- pendente | em_pausa | em_andamento | concluida
  quadro        text not null default 'equipe',   -- equipe | validacao
  validacao     text default 'aguardando',        -- aguardando | validada (só no quadro validacao)
  prazo         date,
  criado_por    text not null,            -- login de quem criou (gestora)
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- Histórico de mudanças de status (linha do tempo da demanda)
create table if not exists demanda_historico (
  id          uuid primary key default gen_random_uuid(),
  demanda_id  uuid not null references demandas(id) on delete cascade,
  tipo        text not null,   -- criada | status | validacao | quadro
  de          text,            -- estado anterior
  para        text,            -- novo estado
  autor       text not null,   -- login de quem fez a mudança
  em          timestamptz not null default now()
);

-- Anexos (metadados; arquivo vai pro Supabase Storage)
create table if not exists demanda_anexos (
  id          uuid primary key default gen_random_uuid(),
  demanda_id  uuid not null references demandas(id) on delete cascade,
  nome        text not null,
  url         text not null,
  criado_em   timestamptz not null default now()
);

-- Índices úteis
create index if not exists idx_demandas_quadro   on demandas(quadro);
create index if not exists idx_demandas_resp      on demandas(responsavel);
create index if not exists idx_hist_demanda       on demanda_historico(demanda_id);
create index if not exists idx_anexos_demanda     on demanda_anexos(demanda_id);

-- ============================================================
-- RLS desabilitado + GRANT (padrão CropApp)
-- ============================================================
alter table demandas          disable row level security;
alter table demanda_historico disable row level security;
alter table demanda_anexos    disable row level security;

grant all on table demandas          to anon, authenticated;
grant all on table demanda_historico to anon, authenticated;
grant all on table demanda_anexos    to anon, authenticated;

-- ============================================================
-- Storage: crie um bucket público chamado 'anexos' pelo painel
-- (Storage > New bucket > name: anexos > Public). Sem isso, os
-- uploads de anexo não funcionam.
-- ============================================================
