------------------------- production middleware --------------------------------
use Rack::Cors
use ActionDispatch::HostAuthorization
use Rack::Sendfile
use ActionDispatch::Static
use ActionDispatch::Executor
// use ActionDispatch::ServerTiming
    // ドキュメントにも何も書かれていなくて、よくわからない
// use ActiveSupport::Cache::Strategy::LocalCache::Middleware
    // LocalCacheを実装したキャッシュは、ブロックの間、メモリ内キャッシュによってバックアップされる。同じキーに対してキャッシュを繰り返し呼び出すと、イン・メモリ・キャッシュがヒットし、より高速にアクセスできるようになる。
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use ActionDispatch::RemoteIp
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use Sentry::Rails::CaptureExceptions
use ActionDispatch::DebugExceptions
use Sentry::Rails::RescuedExceptionInterceptor
// use ActionDispatch::ActionableExceptions
  // ドキュメントに詳しいことは書かれていないが、コントローラー的に重要そう？
// use ActionDispatch::Reloader
  // ActionDispatch::Reloader は、ActiveSupport::Reloader コールバックによって提供されるコールバックでリクエストをラップします。
デフォルトでは、ActionDispatch::Reloaderは開発環境でのみミドルウェアスタックに含まれます。→リクエストに関わるなら、一応入れとく？
use ActionDispatch::Callbacks
// use ActiveRecord::Migration::CheckPending
  // このクラスは、config.active_record.migration_errorが:page_loadに設定されている場合に、ウェブページをロードする前にすべてのマイグレーションが実行されたことを確認するために使用されます。
use ActionDispatch::Cookies
use ActionDispatch::Session::RedisStore
use ActionDispatch::Flash
use ActionDispatch::ContentSecurityPolicy::Middleware
use ActionDispatch::PermissionsPolicy::Middleware
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
use Rack::TempfileReaper
run SimplifiedPrisonerTrainingAppBackend::Application.routes