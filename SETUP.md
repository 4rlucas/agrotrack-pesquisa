# AgroTrack Pesquisa — guia de setup

App de arquivo único (`index.html`) + Supabase. Segue o mesmo padrão que você já usa (RLS off + GRANT).

## 1. Criar o projeto Supabase
1. Crie um **novo projeto** no Supabase (separado do AgroTrack/CropApp).
2. Vá em **SQL Editor** e rode o `schema.sql` inteiro. Ele cria as 3 tabelas (`demandas`, `demanda_historico`, `demanda_anexos`), desabilita RLS e concede GRANT.
3. Em **Storage → New bucket**, crie um bucket **público** chamado `anexos` (só necessário quando for ligar o upload de anexos; o resto funciona sem ele).

## 2. Ligar o app ao Supabase
No topo do `<script>` em `index.html`, troque:

```js
var SUPABASE_URL = 'https://SEU-PROJETO.supabase.co';
var SUPABASE_ANON_KEY = 'SUA-ANON-KEY';
```

Pegue os dois valores em **Settings → API** do projeto (`Project URL` e `anon public`).

## 3. Configurar os logins
Ainda no `<script>`, troque o objeto `USUARIOS` pelos nomes reais. O formato é:

```js
'login':  {senha:'senha123', role:'funcionaria', nome:'Nome Real', cor:'#60a5fa', corBg:'rgba(96,165,250,.15)'},
```

Regras de `role`:
- `gestora` — cria/atribui demandas, vê os dois quadros, envia concluídas p/ validação, marca validação
- `funcionaria` — vê só as próprias demandas, muda status
- `rafael` — vê só o quadro de validação, marca "Validada"

Adicione quantas funcionárias precisar, copiando a linha. Sugestão de cores: azul `#60a5fa`, roxo `#c084fc`, laranja `#fb923c`, rosa `#f472b6`.

> As senhas ficam no código (mesmo esquema do AgroTrack original). É suficiente pra uso interno; se um dia quiser segurança real, dá pra migrar pro Supabase Auth.

## 4. Rodar / publicar
- Localmente: abra o `index.html` no navegador (ou use Live Server no VS Code).
- Publicar: suba a pasta no **Vercel** (novo projeto, separado). É estático, deploy instantâneo.

## Como funciona
- **Quadro 1 (Demandas):** kanban Pendente → Em Pausa → Em Andamento → Concluída. Cada card tem botões pra mudar o status (funciona bem no celular, sem arrastar). A funcionária só vê e mexe nas dela; a gestora vê tudo e filtra por status/responsável.
- **Enviar p/ validação:** quando uma demanda está "Concluída", a gestora vê o botão "→ Enviar p/ validação" no card, que a move pro quadro 2.
- **Quadro 2 (Validação Rafael):** duas colunas — Aguardando validação e Validada. Todas as funcionárias visualizam; gestora e Rafael marcam "Validada". A gestora pode devolver pra equipe se precisar.
- **Histórico:** toda mudança de status/validação/quadro é carimbada com data, hora e autor. Abra qualquer card pra ver a linha do tempo.

## Próximos passos possíveis (quando quiser)
- Upload de anexos real (bucket `anexos` + campo no modal)
- Drag-and-drop de verdade no desktop
- Exportação Excel/PDF do que foi feito no mês
- Coluna "Reprovada" no quadro de validação
