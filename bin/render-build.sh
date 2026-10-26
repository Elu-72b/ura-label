#!/usr/bin/env bash
# Render のビルド時に実行するスクリプト
# 途中で失敗したら止める
set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean

# Free プランには Pre-Deploy Command がないため、ビルド時にマイグレーションを行う
bin/rails db:migrate

# Free プランには Shell もないため、成分の初期データもビルド時に入れる
# (db/seeds.rb は登録済みの成分を飛ばすので、デプロイのたびに実行しても重複しない)
bin/rails db:seed
