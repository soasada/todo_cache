# Config scripts are evaluated in compile time

use Mix.Config

import_config "#{Mix.env()}.exs" # imports the configuration depending on the environment: "config/dev.exs", "config/test.exs" or "config/prod.exs".
