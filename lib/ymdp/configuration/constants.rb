YMDP_ROOT = BASE_PATH unless defined?(YMDP_ROOT)
TMP_DIR = TMP_PATH unless defined?(TMP_DIR)

CONFIG = YMDP::Configuration::Config.new
SERVERS = YMDP::Configuration::Servers.new
