#!/bin/sh

# 证书管理脚本

# 检查必要的环境变量
if [ -z "$DOMAINS_DEV" ] || [ -z "$EMAIL" ]; then
    echo "错误: 缺少必要的环境变量 (DOMAINS_DEV, EMAIL)"
    exit 1
fi

# 创建证书存储目录
mkdir -p "$CERT_PATH/prod"
mkdir -p "$CERT_PATH/dev"

# 申请生产环境证书
apply_prod_certs() {
    if [ -z "$DOMAINS_PROD" ]; then
        echo "跳过生产环境证书申请: DOMAINS_PROD 未配置"
        return 0
    fi

    echo "开始申请生产环境证书..."
    old_IFS=$IFS
    IFS=','
    for domain in $DOMAINS_PROD; do
        echo "为域名 $domain 申请证书"
        if ! certbot certonly --webroot \
            --webroot-path=/var/www/certbot \
            --email "$EMAIL" \
            --agree-tos \
            --no-eff-email \
            -d "$domain" \
            --cert-name "prod-$domain" \
            --keep-until-expiring \
            --non-interactive; then
            echo "警告: 生产环境证书申请失败: $domain"
        fi
    done
    IFS=$old_IFS
}

# 申请开发环境证书
apply_dev_certs() {
    if [ -z "$DOMAINS_DEV" ]; then
        echo "跳过生产环境证书申请: DOMAINS_DEV 未配置"
        return 0
    fi

    echo "开始申请开发环境证书..."
    old_IFS=$IFS
    IFS=','
    for domain in $DOMAINS_DEV; do
        echo "为域名 $domain 申请证书"
        if ! certbot certonly --webroot \
            --webroot-path=/var/www/certbot \
            --email "$EMAIL" \
            --agree-tos \
            --no-eff-email \
            -d "$domain" \
            --cert-name "dev-$domain" \
            --staging \
            --keep-until-expiring \
            --non-interactive; then
            echo "警告: 开发环境证书申请失败: $domain"
        fi
    done
    IFS=$old_IFS
}

# 续期所有证书
renew_certs() {
    echo "检查并续期证书..."
    if ! certbot renew --quiet --non-interactive; then
        echo "警告: 证书续期失败"
        return 1
    fi
    return 0
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
