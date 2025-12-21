#!/bin/bash

# Script para crear recursos aws en LocalStack para La Huella
# Este script debe ejecutarse antes de insertar datos

echo "🌱 Creando recuros en LocalStack..."

# Configuración de variables
REGION="eu-west-1"
ENDPOINT="http://localhost:4566"

# Función para verificar si un comando fue exitoso
check_command() {
    if [ $? -eq 0 ]; then
        echo "✅ $1"
    else
        echo "❌ Error en: $1"
        exit 1
    fi
}

# Productos de ejemplo
echo "📦 Creando tabla de productos..."

aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name la-huella-products \
  --region eu-west-1 \
  --attribute-definitions \
    AttributeName=id,AttributeType=S \
    AttributeName=category,AttributeType=S \
  --key-schema \
    AttributeName=id,KeyType=HASH \
  --provisioned-throughput \
    ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --global-secondary-indexes '[
    {
      "IndexName": "CategoryIndex",
      "KeySchema": [
        { "AttributeName": "category", "KeyType": "HASH" }
      ],
      "Projection": { "ProjectionType": "ALL" },
      "ProvisionedThroughput": {
        "ReadCapacityUnits": 5,
        "WriteCapacityUnits": 5
      }
    }
  ]' \
  --region $REGION 

# Comentarios de ejemplo con diferentes sentimientos
echo "💬 Creando tabla de comentarios..."

aaws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name la-huella-comments \
  --region eu-west-1 \
  --attribute-definitions \
    AttributeName=id,AttributeType=S \
    AttributeName=productId,AttributeType=S \
    AttributeName=createdAt,AttributeType=S \
  --key-schema \
    AttributeName=id,KeyType=HASH \
  --provisioned-throughput \
    ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --global-secondary-indexes '[
    {
      "IndexName": "ProductIndex",
      "KeySchema": [
        { "AttributeName": "productId", "KeyType": "HASH" },
        { "AttributeName": "createdAt", "KeyType": "RANGE" }
      ],
      "Projection": { "ProjectionType": "ALL" },
      "ProvisionedThroughput": {
        "ReadCapacityUnits": 5,
        "WriteCapacityUnits": 5
      }
    }
  ]' \
  --region $REGION


echo "🎉 ¡Tablas de productos y comentarios creadas correctamente!"

echo "🔗 Acceso a LocalStack: http://localhost:4566"