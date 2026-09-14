# Ruby / Rails 学習メモ: モジュール・Concern・コールバック

Rails 8 の `rails g authentication` が生成する `app/controllers/concerns/authentication.rb` を
読み解く過程で理解した概念のまとめ。

対象コード:

```ruby
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def require_authentication
      resume_session || request_authentication
    end
    # ...
end
```

---

## 0. 詰まったときの索引

| 症状・疑問                                                         | 見る節 |
| ------------------------------------------------------------------ | ------ |
| なぜクラスじゃなくてモジュールなの？                               | 1      |
| `concerns/` の「自動読み込み」って何が自動なの？                   | 1      |
| `uninitialized constant` が出た / ファイルを置いたのに認識されない | 1      |
| なぜ `Concerns::Authentication` じゃなくて `Authentication` なの？ | 1      |
| `extend` と `include` の違いが分からない                           | 3      |
| `included do` って何のためにあるの？                               | 4, 5   |
| モジュール直下に `before_action` を書いたらエラーになった          | 4      |
| そもそも `before_action` を書く必要ある？                          | 6      |
| `skip_before_action` はどこで定義されてる？                        | 8      |
| このメソッドどこから来たの？                                       | 9      |
| なんか暗黙の前提が多くて気持ち悪い                                 | 10     |

---

## 1. なぜクラスではなくモジュールなのか

### クラスとモジュールの違い

|                  | クラス                    | モジュール                                   |
| ---------------- | ------------------------- | -------------------------------------------- |
| インスタンス生成 | できる (`User.new`)       | **できない** (`Authentication.new` はエラー) |
| 継承             | **単一継承**。親は1つだけ | 継承されるものではない                       |
| 他への組み込み   | できない                  | **include で何個でも混ぜ込める**             |

### 継承だと足りない理由

```
Api::V1::UsersController
  └─ ApplicationController
       └─ ActionController::API
```

Ruby は単一継承なので、ここに「認証機能を持ったクラス」をもう1枚挟めない。

`ApplicationController` に認証メソッドを直接書くことは可能だが、
認証もエラーハンドリングもログも全部そこに詰まって数百行になる。

モジュールなら **機能ごとにファイルを分けたうえで、必要なクラスに何個でも混ぜられる**。
これが Mixin（他言語でいう多重継承の代替）。

### `app/controllers/concerns/`

Rails が用意している置き場。"Concern" = 関心事 = **1つの機能的なまとまり**。
`app/models/concerns/` にも同じ仕組みがある。

#### 「自動で読み込まれる」の意味

> **重要: 「自動読み込み」= Ruby の `require` が不要、という意味。
> 「どこかのクラスに自動で混ざる」という意味ではない。**

`concerns/` に置いただけでは、どのコントローラにも適用されない。
`ApplicationController` に `include Authentication` と手で書いて初めて機能する
（`rails g authentication` のログに `gsub app/controllers/application_controller.rb`
とあるのが、まさにこの行を差し込んでいる）。

**自動なのは「読み込み」であって「適用」ではない。**

素の Ruby なら本来こう書く必要がある:

```ruby
require_relative 'concerns/authentication'   # これがないと定数が見つからない

class ApplicationController < ActionController::API
  include Authentication
end
```

Rails ではこの `require` を書かない。
`Authentication` という**定数に初めて触れた瞬間**に、Rails が
「その名前のファイルがどこかにあるはず」と探しに行き、見つけたらその場で読み込む。

これが自動読み込み（autoloading）。Rails 6 以降は **Zeitwerk** が担当している。

#### どこを探しに行くのか（オートロードパス）

`app/` 直下のディレクトリは基本的に全部登録される
（`app/models`, `app/controllers`, `app/jobs`, `app/mailers` など）。

通常は**オートロードパスからの相対パスが定数名に対応する**。

```
app/controllers/admin/users_controller.rb  →  Admin::UsersController
```

ディレクトリ名がモジュールのネストになる。

#### なぜ `Concerns::Authentication` ではなく `Authentication` なのか

上のルールをそのまま当てはめると
`app/controllers/concerns/authentication.rb` は `Concerns::Authentication` のはず。
でも実際は `Authentication`。

**理由: `concerns` ディレクトリ自体がオートロードパスとして登録されているから。**
`app/controllers` と `app/controllers/concerns` の**両方がルート扱い**になる。
だから `concerns/` からの相対パスで名前が決まり、`Concerns::` が付かない。

これは Rails が明示的にそう設定しているもので、他のディレクトリ名では起きない。
`app/controllers/helpers/foo.rb` を作れば普通に `Helpers::Foo` になる。

#### 命名規約がすべて

Zeitwerk は**ファイル名から定数名を推測する**ので、ずれると動かない。

| ファイル                     | 期待される定数   |
| ---------------------------- | ---------------- |
| `concerns/authentication.rb` | `Authentication` |
| `concerns/api_response.rb`   | `ApiResponse`    |
| `concerns/user_scoped.rb`    | `UserScoped`     |

スネークケース → キャメルケースの単純変換。

**ハマりどころ: 頭字語。**
`concerns/api_response.rb` の中身を `APIResponse` と定義すると、
Zeitwerk は `ApiResponse` を期待しているのでエラーになる。
`APIResponse` にしたいなら `config/initializers/inflections.rb` で頭字語を登録する。

**ファイルを置いたのに定数が見つからないとき**は、たいてい命名か置き場所のずれ。

```bash
bin/rails zeitwerk:check   # 規約に反しているファイルを教えてくれる
```

#### 開発環境ではリロードも働く

ファイルを保存すると次のリクエストで読み直される（サーバー再起動が不要な理由）。

ただし例外あり:

- `config/` 以下を変えたとき → **再起動が必要**
- `lib/`（デフォルトではオートロード対象外）→ 同上

「コードを直したのに反映されない」ときは、まずここを疑う。
本番環境では起動時に全部読み込む（eager loading）ので、リロードは起きない。

#### エラーからの切り分け

「読み込まれる」が Ruby の `require` の話なのか、`include` の話なのかを区別しておくと、
エラーメッセージの読み分けができる。

| エラー                                                     | 意味                                                   |
| ---------------------------------------------------------- | ------------------------------------------------------ |
| `NameError: uninitialized constant Authentication`         | **読み込み**の問題。ファイル名・置き場所・定数名のずれ |
| `NoMethodError: undefined method 'require_authentication'` | **適用**の問題。`include` を書き忘れている             |

---

## 2. クラスの中には「2つの世界」がある

**Ruby のクラス定義は、上から下に実行されるコード**。ただの宣言ではない。

```ruby
class Foo
  puts "ここは読み込み時に実行される"

  def bar
    puts "ここは bar が呼ばれるまで実行されない"
  end
end
```

これを読み込むと、1つ目の puts だけが表示される。

| 場所             | いつ走るか                 |
| ---------------- | -------------------------- |
| `def` の**外側** | クラス定義の読み込み時     |
| `def` の**中身** | そのメソッドが呼ばれたとき |

この区別が、以降の話の全ての土台になる。

---

## 3. `include` と `extend`

| 書き方               | 取り込まれたメソッドは                                     |
| -------------------- | ---------------------------------------------------------- |
| `include SomeModule` | **インスタンスメソッド**になる                             |
| `extend SomeModule`  | **クラスメソッド**（正確にはレシーバの特異メソッド）になる |

対象コードでの使い分け:

- `Authentication` の1行目 `extend ActiveSupport::Concern`
  → `included do` や `class_methods do` という記述を、
  **`Authentication` モジュール自身のクラスメソッドとして使いたい**から `extend`
- `ApplicationController` 側の `include Authentication`
  → 認証メソッドを**インスタンスメソッドとして**取り込みたいから `include`

---

## 4. モジュール直下に `before_action` を書けない理由

### `before_action` はただのメソッド呼び出し

```ruby
class ApplicationController < ActionController::API
  before_action :require_authentication   # ← 定義時に走る「メソッド呼び出し」
end
```

Rails の特別な構文ではない。`ActionController::API` が持っているクラスメソッドを、
`ApplicationController` 自身に対して呼んでいるだけ。

### モジュールに書くと壊れる

```ruby
module Authentication
  before_action :require_authentication   # ← NoMethodError
end
```

```
NoMethodError: undefined method 'before_action' for Authentication:Module
```

**理由**: この行が実行されるのは**モジュールの定義時**で、そのときのレシーバは
`Authentication` モジュール自身。モジュールは `ActionController::API` を継承していないので、
`before_action` を持っていない。

呼びたい相手は include 先のコントローラなのに、レシーバがモジュールになってしまう。

### タイミングの問題でもある

モジュールの定義は、`include` される**前**に読み込まれる。
定義した時点では、誰がこれを include するのかまだ分からない。

→ 「include されたあとで、include した相手に対して呼ぶ」必要がある。

### まとめ表

| 書く場所                        | レシーバ（= 誰に対する呼び出しか） | `before_action` は |
| ------------------------------- | ---------------------------------- | ------------------ |
| クラスの `def` の外             | そのクラス                         | 使える             |
| モジュールの `def` の外         | **そのモジュール**                 | **使えない**       |
| モジュールの `included do` の中 | **include したクラス**             | 使える             |

> 確認方法: `included do` を外して直接書き、実際に `NoMethodError` を見る。
> エラーに `for Authentication:Module` と出るので、レシーバがモジュールであることが目で見える。
> **わざと壊して確認する**のは仕組みを理解するのにかなり有効（git があれば戻すのも簡単）。

---

## 5. `ActiveSupport::Concern` が隠しているもの

### 素の Ruby で書くとこうなる

```ruby
module Authentication
  def self.included(base)        # include された瞬間に呼ばれるフック
    base.before_action :require_authentication   # base = include した側のクラス
    base.extend(ClassMethods)
  end

  module ClassMethods
    def allow_unauthenticated_access(**options)
      # ...
    end
  end
end
```

動くが定型文が長い。モジュール同士に依存関係があるとさらに複雑になる。

### `ActiveSupport::Concern` を使うと

| 書き方                     | 意味                                                                                              |
| -------------------------- | ------------------------------------------------------------------------------------------------- |
| `included do ... end`      | **実行を遅らせて保存**しておき、include された瞬間に **include した側のクラスの文脈で**実行する箱 |
| `class_methods do ... end` | 中で定義したものが、include した側の**クラスメソッド**になる                                      |
| `private` 以下の `def`     | include した側の**インスタンスメソッド**になる                                                    |

やっていることは素の書き方と同じ。定型文を隠しているだけ。

### 3層構造として読む

```ruby
module Authentication
  extend ActiveSupport::Concern   # included / class_methods が使えるようになる

  included do                     # ① include 先のクラス定義時に実行される
    before_action :require_authentication
  end

  class_methods do                # ② include 先のクラスメソッドになる
    def allow_unauthenticated_access(...)
  end

  private
    def require_authentication    # ③ include 先のインスタンスメソッドになる
```

**`included do` の中の `self` はモジュールではなく include したクラス**。
ここを混同すると「なぜここで before_action が使えるのか」が分からなくなる。

---

## 6. そもそもなぜ `before_action` を登録するのか

### メソッドがあることと、呼ばれることは別

`include` しただけだと `require_authentication` は**存在するが誰も呼ばない**。

### 方法1: 各アクションで自分で呼ぶ（ダメな例）

```ruby
def index
  require_authentication   # 毎回書く
  # ...
end

def show
  # ← 書き忘れた。エラーは出ない。動いてしまう。だから気づかない
end
```

認証で一番危ない事故がこれ。
「ログイン必須のはずのエンドポイントが、実は誰でも叩けた」。

### 方法2: `before_action` に登録する

```ruby
class ApplicationController < ActionController::API
  before_action :require_authentication
end
```

**すべてのアクションの前に自動で呼ばれる**。書き忘れが原理的に起きない。
そして「ログイン不要なもの」だけを例外として明示する。

> **原則: デフォルトで全部守り、例外だけ穴を開ける。**
> 逆にすると、穴を塞ぎ忘れたときに無防備になる。

### なぜ「include と一緒に」やりたいのか

手で書くならこうなる:

```ruby
class ApplicationController < ActionController::API
  include Authentication                  # メソッドを取り込む
  before_action :require_authentication   # 呼ぶ設定をする
end
```

これでも動く。小さいアプリなら何も問題ない。

ただし **2行セットで書かないと機能しない**（片方だけだと「メソッドはあるが誰も呼ばない」）。
これは認証モジュール側の都合なのに、使う側が知っていなければならない知識になっている。

`included do` を使えば、**`include` 1行でモジュールが自己完結する**。

> `included do` が本当に効いてくるのは、モジュールが複数クラスで使われるときや、
> モジュールが増えてきたとき。それぞれに「使うときはこの3行も書いてね」が
> 付いていたらすぐ破綻する。

---

## 7. 継承先への波及と、例外指定

### 継承したコントローラ全部に効く

`before_action` の登録は `ApplicationController` に保持され、**継承先に引き継がれる**。

```
ApplicationController          ← ここに include Authentication
  ├─ Api::V1::UsersController      ← 一行も書かなくても認証必須
  ├─ Api::V1::SessionsController   ← 同上
  └─ Api::V1::WorkoutsController   ← 今後作るものも同上
```

### 例外を開ける

```ruby
class Api::V1::UsersController < ApplicationController
  allow_unauthenticated_access only: :create
end
```

中身は `skip_before_action :require_authentication, **options` を呼んでいるだけ。

### 実務上の注意

- **ユーザー登録 (`users#create`) を除外しないと、登録するのにログインが必要**になる
- **ログイン (`sessions#create`) も同様**。ログインするのにログインが必要になる
- `skip_before_action` は、登録されていないコールバックをスキップしようとすると
  `ArgumentError` になる（デフォルトが `raise: true`）。
  → **先に `before_action` を用意してから例外指定を書く**
- `GET /up`（ヘルスチェック）は `rails/health#show`。
  `ApplicationController` を継承していないので影響を受けない

### エンドポイントの棚卸し（増える前にやる）

| エンドポイント                        | 認証 |
| ------------------------------------- | ---- |
| `POST /api/v1/users` (登録)           | 不要 |
| `GET/PATCH/DELETE /api/v1/users/:id`  | 必要 |
| `POST /api/v1/session` (ログイン)     | 不要 |
| `DELETE /api/v1/session` (ログアウト) | 必要 |

---

## 8. `skip_before_action` はどこで定義されているか

**`AbstractController::Callbacks::ClassMethods`**

```
ActiveSupport::Callbacks          ← Rails 全体の基盤
  └─ AbstractController::Callbacks  ← before_action / skip_before_action など
       └─ ActionController::API が include
            └─ ApplicationController が継承
                 └─ Api::V1::UsersController が継承
```

ActiveRecord の `before_save` / `after_create` も同じ `ActiveSupport::Callbacks` の上に乗っている。
`before_action` と `before_save` が似た書き味なのは偶然ではない。

### なぜモジュールの中から呼べるのか

```ruby
class_methods do
  def allow_unauthenticated_access(**options)
    skip_before_action :require_authentication, **options
  end
end
```

この `def` の中身が実行されるのは**呼ばれたとき**。呼ばれる形は:

```ruby
class Api::V1::UsersController < ApplicationController
  allow_unauthenticated_access only: :create   # ← レシーバは UsersController
end
```

→ メソッド内の `skip_before_action` の暗黙のレシーバ `self` も `UsersController`。
`UsersController` は `ActionController::API` の子孫なので持っている。

**4節の `included do` と同じ構造**: モジュールに書いてあっても、実行時のレシーバは include 先。

---

## 9. 「このメソッドどこから来たの？」の調べ方

`rails console` で使える。Rails は継承と mixin が深いので、
ソースを追うよりこちらのほうが速いことが多い。

```ruby
# クラスメソッドの定義元モジュール
Api::V1::UsersController.method(:skip_before_action).owner
# => AbstractController::Callbacks::ClassMethods

# ファイルパスと行番号（そのまま開いて読める）
Api::V1::UsersController.method(:skip_before_action).source_location

# インスタンスメソッドの場合
Api::V1::UsersController.instance_method(:render).owner

# 積み重なっているモジュール一覧（Authentication も途中にいる）
Api::V1::UsersController.ancestors
```

**Ruby のメソッド探索は `ancestors` のリストを上から順に見ていく。**
「なぜこのメソッドが呼べるのか」の答えは、常にこのリストの中にある。

一度眺めておくと、Rails が自分のコントローラに何を混ぜ込んでいるかが体感できる。

---

## 10. この設計の弱点（違和感は正しい）

### Concern は include 先に暗黙の要求を持つ

`Authentication` は、include 先に対してこれらを要求している。**コードには一切書かれていない**。

- `before_action` / `skip_before_action` を持つこと（= コントローラであること）
- `cookies` / `request` / `redirect_to` が使えること
- `helper_method` を持つこと（= フルスタックであること）

違反すると `NoMethodError`。サーバー起動時だったり、実行時だったりする。

Ruby には「このモジュールはこういうインターフェースを要求する」を宣言する言語機能がない
（Java の interface、Rust の trait bound にあたるもの）。
これは **duck typing の代償**。

### 実際に痛くなる場面

- **再利用できない**: ActionCable の `Connection::Base` は `before_action` を持たないので使えない
- **単体テストできない**: 必ずコントローラごと動かす必要がある
- **依存の方向が逆**: 「認証」はドメインに近い関心事なのに、
  Web フレームワークの都合（before_action, cookies, request）に強く縛られている

→ これを嫌う場合、認証ロジックを素の Ruby オブジェクトに切り出し、
Concern は薄いアダプタにする設計を採る。

### 一方で、こうなっている理由

- 生成コードは**gem ではなく自分のアプリのコード**。
  「このアプリのコントローラで使う」と文脈が確定しているので、汎用化する動機が弱い
- Rails は歴史的に**抽象化を先回りしない**文化。
  1箇所でしか使わないものを汎用化するコストのほうが高い、という判断
- 暗黙の前提は **命名と配置**で伝える運用になっている
  （`app/controllers/concerns/` に置いてある = コントローラに include するもの）。
  これが「設定より規約」の実体

### 持っておくとよい姿勢

1. Rails のコードを読むときは「このモジュールは何を前提にしているか」を自分で拾う。
   型が教えてくれないので読解でカバーする（9節の道具がそのため）
2. 自分で Concern を書くときは前提をコメントに書く。
   「ActionController::Base/API を継承したクラスで使うこと」の1行で、半年後の自分が助かる
3. **「これは Rails の作法であって、良い設計の普遍原理ではない」と区別しておく。**
   他の言語・フレームワークを触ったときに、この違和感が理解の足がかりになる

---

## 11. API モードに移植するときの注意

生成コードはフルスタック Rails 前提。`ActionController::API` にそのまま持ってくると壊れる箇所:

| 生成コード                                                 | 問題                                                                                   | 対処                                                                           |
| ---------------------------------------------------------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `helper_method :authenticated?`                            | `ActionController::API` にビューがなく、このメソッド自体が存在しない → `NoMethodError` | 行ごと削除                                                                     |
| `request_authentication` の `redirect_to new_session_path` | JSON API にリダイレクト先がない                                                        | 401 を返す形に書き換え                                                         |
| `session[:return_to_after_authenticating]`                 | API モードはセッションミドルウェアが外れている                                         | 不要なので削除                                                                 |
| `cookies.signed`                                           | `ActionController::Cookies` の include が必要                                          | コントローラ側で include                                                       |
| カラム名 `email_address`                                   | 自分は `email` で作っている                                                            | どちらかに揃える（`normalizes`, `find_by` など散らばっているので見落とし注意） |

---

## 12. 一枚まとめ

```ruby
module Authentication
  extend ActiveSupport::Concern
  # ↑ extend = このモジュール自身のクラスメソッドとして
  #   included / class_methods を使えるようにする

  included do
    # ↑ 実行を遅らせる箱。include された瞬間、include 先のクラスの文脈で実行される
    #   ここの self = ApplicationController（モジュールではない）
    #   だから before_action が呼べる
    before_action :require_authentication
  end

  class_methods do
    # ↑ ここで定義したものは include 先のクラスメソッドになる
    def allow_unauthenticated_access(**options)
      # 呼ばれるときのレシーバは UsersController なので
      # skip_before_action(= AbstractController::Callbacks 由来) が使える
      skip_before_action :require_authentication, **options
    end
  end

  private
    # ↑ ここは include 先の private インスタンスメソッドになる
    def require_authentication
    end
end
```

**3つの合言葉**

1. **クラスの中には2つの世界がある** — `def` の外は定義時、中は呼び出し時
2. **レシーバは誰か** — モジュール直下なら「モジュール」、`included do` の中なら「include 先のクラス」
3. **定義と呼び出しは別** — `include` でメソッドは生えるが、`before_action` がないと誰も呼ばない
