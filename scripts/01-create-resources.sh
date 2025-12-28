#!/bin/bash

# Script para crear recursos aws en LocalStack para La Huella
# Este script debe ejecutarse antes de insertar datos

echo "🌱 Creando recursos en LocalStack..."

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

echo "Creando tabla de productos..."

aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name la-huella-products \
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

echo "Creando tabla de comentarios..."

aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name la-huella-comments \
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

echo "Creando tabla de analytics..."

aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name la-huella-analytics \
  --attribute-definitions \
    AttributeName=id,AttributeType=S \
    AttributeName=date,AttributeType=S \
  --key-schema \
    AttributeName=id,KeyType=HASH \
    AttributeName=date,KeyType=RANGE \
  --provisioned-throughput \
    ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region $REGION


echo "📦 Creando buckets..."

aws --endpoint-url=http://localhost:4566 s3 mb s3://la-huella-sentiment-reports
  --region $REGION

aws --endpoint-url=http://localhost:4566 s3 mb s3://la-huella-uploads
  --region $REGION

echo "📦 Creando colas SQS..."

aws --endpoint-url=http://localhost:4566 sqs create-queue \
  --queue-name la-huella-processing-queue \
  --region $REGION

aws --endpoint-url=http://localhost:4566 sqs create-queue \
  --queue-name la-huella-notifications-queue \
  --region $REGION  

aws --endpoint-url=http://localhost:4566 sqs create-queue \
  --queue-name la-huella-processing-dlq \
  --region $REGION

  echo "📦 Creando colas SQS..."

aws --endpoint-url=http://localhost:4566 logs create-log-group --log-group-name --region $REGION /la-huella/sentiment-analysis

aws --endpoint-url=http://localhost:4566 logs create-log-group --log-group-name --region $REGION /la-huella/api


echo "🎉 ¡Tablas de productos y comentarios, colas SQS, Buckets, Grupos de Logs creados correctamente!"

echo "🔗 Acceso a LocalStack: http://localhost:4566"