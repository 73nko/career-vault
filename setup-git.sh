#!/usr/bin/env bash
# setup-git.sh: inicializa el repo del vault y lo sube a GitHub.
# Ejecutar UNA sola vez desde la carpeta del vault.
# Requisitos: gh CLI instalado y autenticado (`gh auth login`).

set -euo pipefail

cd "$(dirname "$0")"

# 0. Limpiar cualquier .git parcial que el sandbox haya dejado
if [ -d .git ]; then
  echo "Eliminando .git previo..."
  rm -rf .git
fi

# 1. Init limpio
git init -b main
git config user.email "apramos89@gmail.com"
git config user.name "Alex Ramos"

# 2. Add + commit inicial
git add .
git commit -m "chore: initial vault setup

- Estructura por dominios (00_Inbox a 06_Interviews + 99_Templates)
- Plan trimestral Q1-Q4 con cronograma semanal de Q1
- Plantillas Templater: Daily, Weekly, Monthly, Quarterly, Concept,
  Book, ADR, STAR Story, Company Research, Algorithm Problem
- MOCs iniciales: Frontend, Backend, SystemDesign, Algorithms
- Project Overview del SDK Web Vitals
- Plugins community: Templater, Dataview, Excalidraw, Periodic Notes,
  Calendar, Tasks, Git
- Theme Things (dark) + snippet custom"

# 3. Crear repo público en GitHub y push
gh repo create career-vault \
  --public \
  --source=. \
  --remote=origin \
  --description "Vault personal: camino a Staff Engineer (12 meses, ~310h)" \
  --push

echo
echo "Listo. Repo: https://github.com/73nko/career-vault"
echo
echo "Borra este script si quieres: rm setup-git.sh"
