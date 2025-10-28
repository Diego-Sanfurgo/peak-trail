#!/bin/bash


# ==============================
# VARIABLES DE ENTORNO
# ==============================


# Cargar variables desde .env.dev
set -a
source .env.dev
set +a


# ==============================
# COMANDO A EJECUTAR
# ==============================
# Ejemplo: ./scripts/env.sh run
# Ejemplo: ./scripts/env.sh build apk
CMD=$@


# ==============================
# EJECUTAR FLUTTER CON VARIABLES
# ==============================
flutter $CMD \
 --dart-define=MAPBOX_TOKEN=$AUTH0_CLIENT_ID \
 #--dart-define=AUTH0_CLIENT_SECRET=$AUTH0_CLIENT_SECRET \
 #--dart-define=AUTH0_USERS_CONNECTION=$AUTH0_USERS_CONNECTION \
 #--dart-define=AUTH0_AUDIENCE_ID=$AUTH0_AUDIENCE_ID \
 #--dart-define=PUSHER_CLUSTER=$PUSHER_CLUSTER \
 #--dart-define=PUSHER_MOVE_PROD_API_KEY=$PUSHER_MOVE_PROD_API_KEY \
 #--dart-define=PUSHER_MOVE_PROD_SECRET=$PUSHER_MOVE_PROD_SECRET \
 #--dart-define=PUSHER_BEAMS_INSTANCE_ID=$PUSHER_BEAMS_INSTANCE_ID \
 #--dart-define=MAPS_API_KEY=$MAPS_API_KEY \
# --dart-define=SENTRY_DSN=$SENTRY_DSN
