# ER図 — うらラベル(ura-label)

テーブル・カラム・関連の設計図。テーブルの作成・変更(マイグレーション・モデル)を計画・レビューするときに参照する。

> - 「【案】」は未確定。フェーズ1の着手前に決めたら、このファイルを更新する
> - 実際の DB の状態は `db/schema.rb` が正。この図と食い違ったら、どちらに合わせるかを相談する

---

## ER図

```mermaid
erDiagram
    users ||--o{ sessions : "ログイン状態"
    users ||--o{ favorite_ingredients : "登録する"
    ingredients ||--o{ favorite_ingredients : "登録される"
    users ||--o{ search_histories : "保存する"

    ingredients {
        bigint id PK
        string name UK "成分名(正規化して保存)NOT NULL"
        string inci_name "INCI名"
        string reading "読み(カナ)五十音順用【案】"
        string aliases "別名・表記ゆれ【案】配列か別テーブルか"
        integer caution_level "注意度1〜5 NOT NULL デフォルトの有無は【案】"
        string category "絞り込み用(保湿・防腐など)"
        string purpose "主な配合目的(文章)"
        text description "説明"
        string source "出典名"
        string source_url "出典URL"
        date source_accessed_on "参照日【案】"
        boolean ai_generated "AI生成か NOT NULL default false"
        string verification_status "確認状態【案】ai_generatedとは別"
        datetime ai_generated_at "AI生成日(フェーズ3)"
        datetime manually_edited_at "最終編集日・手動(フェーズ3)"
        datetime created_at
        datetime updated_at
    }

    users {
        bigint id PK
        string email_address UK "NOT NULL(フェーズ7)"
        string password_digest "NOT NULL"
        boolean save_search_history "NOT NULL default false"
        boolean admin "NOT NULL default false(フェーズ9)"
        datetime created_at
        datetime updated_at
    }

    sessions {
        bigint id PK
        bigint user_id FK
        string ip_address
        string user_agent
        datetime created_at
        datetime updated_at
    }

    favorite_ingredients {
        bigint id PK
        bigint user_id FK "user_idとingredient_idの組でユニーク"
        bigint ingredient_id FK
        datetime created_at
        datetime updated_at
    }

    search_histories {
        bigint id PK
        bigint user_id FK
        integer input_type "enum manual・paste・camera"
        text query "入力した成分名。画像は保存しない"
        datetime created_at
        datetime updated_at
    }
```

## テーブルを作るフェーズ

| テーブル | フェーズ |
| --- | --- |
| `ingredients` | 1(`ai_generated_at` / `manually_edited_at` は 3 で追加) |
| `users` / `sessions` | 7(`admin` は 9 で追加) |
| `favorite_ingredients` / `search_histories` | 7 |

## 設計の意図

1. **ingredients は1テーブルにまとめる**: 出典・カテゴリのテーブル分割は今はやらない。項目ごとに出典を検証したくなった段階で `IngredientSource` などを提案する
2. **`ai_generated` と `verification_status` は別のカラム**: 「AI生成か」と「確認済みか」は別の属性
3. **表示する日付は専用のカラムで持つ**: `ai_generated_at` / `manually_edited_at`。`updated_at` は自動の処理でも変わるため表示に使わない。手動で編集しても `ai_generated` と `ai_generated_at` は変えない
4. **search_histories と ingredients は直接つながない**: `query` に入力した文字列をそのまま保存する。未登録・取得失敗の成分も履歴に残せる
5. **退会時はまとめて削除**: `users` に `dependent: :destroy` を付け、気になる成分・検索履歴・セッションを削除する
6. **ログインしていない利用者のデータは保存しない**: `search_histories.user_id` は NOT NULL
7. **未登録・取得失敗の成分は保存しない**: 画面に表示するだけにし、注意度3で登録されないようにする

## 未確定の点(フェーズ1で相談)

- **aliases の持ち方**: PostgreSQL の配列カラムか、`ingredient_aliases` テーブルか(別名もあいまい検索するなら、別テーブルのほうがインデックスを張りやすい)
- **`caution_level` のデフォルト**: 未登録・取得失敗は保存しないので、デフォルトなし(登録時に必ず指定)が意図に合う
- **`category` を1つにするか**: 複数の目的がある成分(保湿と増粘など)を配列で持つか
- **`verification_status` の値**: 未確認・確認済みの2つか、ほかの状態も持つか
- **`reading` / `source_accessed_on` を持たせるか**
