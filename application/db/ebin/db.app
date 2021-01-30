{application, db,
 [
  {description, ""},
  {vsn, "1"},
  {registered, []},
  {applications, [
                  kernel,
                  stdlib,
                  mnesia,
                  lager
                 ]},
  {mod, { db_app, []}},
  {env, [{table_transfer, []},
		{data_files, ["game.config"]}
		]}
 ]}.



