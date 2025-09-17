# ---------------------------------------------------------------------------
# Dockerfile Final para Aplicação Laravel com Nginx (Ambiente de Desenvolvimento)
# ---------------------------------------------------------------------------

# Etapa 1: Imagem Base
# Usamos uma imagem leve do Nginx baseada no Alpine Linux.
FROM nginx:stable-alpine

# Etapa 2: Argumentos de Build para Permissões
# Define argumentos para o ID de usuário (PUID) e de grupo (PGID).
# Isso permite que os arquivos do container tenham a mesma permissão do seu usuário no host,
# resolvendo o erro "403 Forbidden".
ARG PUID=1000
ARG PGID=1000

# Etapa 3: Criação de Usuário e Grupo
# Cria um grupo e um usuário (chamados 'laravel') com os IDs especificados durante o build.
RUN addgroup -g ${PGID} laravel && \
    adduser -D -S -s /bin/sh -u ${PUID} -g laravel laravel

# Etapa 4: Configuração do Nginx
# Cria o diretório web que será usado pela aplicação.
RUN mkdir -p /var/www/html/public

# Copia o arquivo de configuração do Nginx (ex: default.conf) para dentro do container.
ADD nginx/default.conf /etc/nginx/conf.d/default.conf

# Modifica o arquivo de configuração principal do Nginx para que ele rode com nosso usuário 'laravel'.
# A imagem alpine usa 'nginx' como usuário padrão, então substituímos essa linha.
RUN sed -i "s/user nginx;/user laravel;/g" /etc/nginx/nginx.conf

# Etapa 5: Correção de Permissões Internas do Nginx
# Cria os diretórios necessários e dá ao nosso usuário a propriedade deles.
# Isso é crucial para rodar o Nginx como um usuário não-root, resolvendo o erro "Permission denied"
# ao tentar criar arquivos de cache/pid.

RUN mkdir -p /var/lib/nginx && \
    mkdir -p /var/cache/nginx && \
    mkdir -p /var/run/nginx && \
    chown -R laravel:laravel /var/lib/nginx && \
    chown -R laravel:laravel /var/cache/nginx