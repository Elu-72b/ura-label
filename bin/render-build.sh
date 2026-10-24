#!/usr/bin/env bash
# Render のビルド時に実行するスクリプト
# 途中で失敗したら止める
set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean

# Free プランには Pre-Deploy Command がないため、ビルド時にマイグレーションを行う
bin/rails db:migrate
