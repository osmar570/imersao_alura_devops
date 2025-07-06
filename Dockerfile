# Estágio 1: Builder - Onde as dependências são instaladas
FROM python:3.13.4-alpine3.22 AS builder

# Instala dependências do sistema necessárias para compilar pacotes Python
# Elas não estarão na imagem final
RUN apk add --no-cache gcc musl-dev libffi-dev

# Define o diretório de trabalho
WORKDIR /app

# Cria um ambiente virtual isolado
RUN python -m venv /opt/venv
# Adiciona o venv ao PATH
ENV PATH="/opt/venv/bin:$PATH"

# Copia o arquivo de dependências para aproveitar o cache do Docker
COPY requirements.txt ./

# Instala as dependências do Python no ambiente virtual
RUN pip install --no-cache-dir -r requirements.txt

# Estágio 2: Final - A imagem que será executada
FROM python:3.13.4-alpine3.22

WORKDIR /app

# Copia o ambiente virtual com as dependências do estágio builder
COPY --from=builder /opt/venv /opt/venv

# Copia o código da aplicação
COPY . .

# Ativa o ambiente virtual para o container final
ENV PATH="/opt/venv/bin:$PATH"

# Cria um usuário e grupo não-root para rodar a aplicação
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expõe a porta padrão do FastAPI/Uvicorn
EXPOSE 8000

# Comando para iniciar o servidor
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
