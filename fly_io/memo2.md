------------------------- production middleware --------------------------------
use Rack::Cors
use ActionDispatch::HostAuthorization
use Rack::Sendfile
use ActionDispatch::Static
use ActionDispatch::Executor
// use ActionDispatch::ServerTiming
// use ActiveSupport::Cache::Strategy::LocalCache::Middleware
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
// use ActionDispatch::Reloader
use ActionDispatch::Callbacks
// use ActiveRecord::Migration::CheckPending
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