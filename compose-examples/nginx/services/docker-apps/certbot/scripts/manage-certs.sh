#!/bin/bash

# 证书管理脚本

# 检查必要的环境变量
if [ -z "$DOMAINS_PROD" ] || [ -z "$DOMAINS_DEV" ] || [ -z "$EMAIL" ]; then
    echo "错误: 缺少必要的环境变量 (DOMAINS_PROD, DOMAINS_DEV, EMAIL)"
    exit 1
fi

# 创建证书存储目录
mkdir -p "$CERT_PATH/prod"
mkdir -p "$CERT_PATH/dev"

# 申请生产环境证书
apply_prod_certs() {
    echo "开始申请生产环境证书..."
    IFS=',' read -ra DOMAINS <<< "$DOMAINS_PROD"
    for domain in "${DOMAINS[@]}"; do
        echo "为域名 $domain 申请证书"
        certbot certonly --webroot \
            --webroot-path=/var/www/certbot \
            --email "$EMAIL" \
            --agree-tos \
            --no-eff-email \
            -d "$domain" \
            --cert-name "prod-$domain"
    done
}

# 申请开发环境证书
apply_dev_certs() {
    echo "开始申请开发环境证书..."
    IFS=',' read -ra DOMAINS <<< "$DOMAINS_DEV"
    for domain in "${DOMAINS[@]}"; do
        echo "为域名 $domain 申请证书"
        certbot certonly --webroot \
            --webroot-path=/var/www/certbot \
            --email "$EMAIL" \
            --agree-tos \
            --no-eff-email \
            -d "$domain" \
            --cert-name "dev-$domain"
    done
}

# 续期所有证书
renew_certs() {
    echo "检查并续期证书..."
    certbot renew --quiet
}

# 主函数
main() {
    # 首次运行时申请证书
    apply_prod_certs
    apply_dev_certs

    # 定期检查并续期证书
    while true; do
        renew_certs
        sleep "${RENEW_INTERVAL:-12h}"
    done
}

# 运行主函数
main
