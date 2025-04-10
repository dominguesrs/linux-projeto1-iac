#!/bin/bash

# --- Configuração ---
# Lista de usuários a serem criados, separados por espaço
USERS_LIST="Guest10 Guest11 Guest12 Guest13"

# Senha padrão para os usuários
# !!! ATENÇÃO: RISCO DE SEGURANÇA !!!
# Manter senhas em texto plano em scripts é altamente inseguro.
# Considere solicitar a senha ou usar métodos mais seguros em produção.
DEFAULT_PASSWORD="SuaSenhaSecreta123@"

# --- Início do Script ---
echo "Iniciando criação e configuração dos usuários..."

# Loop através de cada usuário na lista
for username in $USERS_LIST; do
  echo "----------------------------------------"
  echo "Processando usuário: $username"

  # 1. Verificar se o usuário já existe
  if id "$username" &>/dev/null; then
    echo "Usuário '$username' já existe. Pulando criação."
  else
    # 2. Criar o usuário (se não existir)
    useradd "$username" -c "Usuário Convidado ($username)" -s /bin/bash -m
    if [ $? -eq 0 ]; then
      echo "Usuário '$username' criado com sucesso."
    else
      echo "ERRO: Falha ao criar usuário '$username'. Pulando para o próximo."
      continue # Pula para o próximo usuário do loop
    fi
  fi

  # 3. Definir a senha usando chpasswd
  echo "$username:$DEFAULT_PASSWORD" | chpasswd
  if [ $? -eq 0 ]; then
    echo "Senha definida para '$username'."
  else
    echo "ERRO: Falha ao definir a senha para '$username'."
    # Considerar o que fazer aqui - talvez remover o usuário? Por enquanto, só avisa.
  fi

  # 4. Expirar a senha (forçar troca no primeiro login)
  passwd "$username" -e &>/dev/null # Redireciona saída para não poluir
  if [ $? -eq 0 ]; then
    echo "Senha de '$username' configurada para expirar no primeiro login."
  else
    echo "AVISO: Falha ao configurar expiração de senha para '$username'."
  fi

done # Fim do loop for

echo "----------------------------------------"
echo "Processo concluído."

# --- Fim do Script ---
