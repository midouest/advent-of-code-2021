import Config

try do
  import_config("secret.exs")
rescue
  File.Error ->
    nil
end
