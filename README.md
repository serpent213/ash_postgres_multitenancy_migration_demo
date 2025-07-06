# AshPostgres context multi-tenancy migration error demo

```
mix ash.reset
mix ash_postgres.generate_migrations --dev
mix ash.migrate
```
↓
```
10:09:16.855 [info] == Running 20250706080910 Demo.Repo.Migrations.MigrateResources1.up/0 forward

10:09:16.856 [info] create table users

10:09:16.858 [info] drop constraint api_keys_user_id_fkey from table api_keys
** (Postgrex.Error) ERROR 42704 (undefined_object) constraint "api_keys_user_id_fkey" of relation "api_keys" does not exist
    (ecto_sql 3.13.2) lib/ecto/adapters/sql.ex:1098: Ecto.Adapters.SQL.raise_sql_call_error/1
    (elixir 1.18.3) lib/enum.ex:1714: Enum."-map/2-lists^map/1-1-"/2
    (ecto_sql 3.13.2) lib/ecto/adapters/sql.ex:1219: Ecto.Adapters.SQL.execute_ddl/4
    (ecto_sql 3.13.2) lib/ecto/migration/runner.ex:348: Ecto.Migration.Runner.log_and_execute_ddl/3
    (elixir 1.18.3) lib/enum.ex:1714: Enum."-map/2-lists^map/1-1-"/2
    (elixir 1.18.3) lib/enum.ex:1714: Enum."-map/2-lists^map/1-1-"/2
    (ecto_sql 3.13.2) lib/ecto/migration/runner.ex:311: Ecto.Migration.Runner.perform_operation/3
    (stdlib 6.2.2) timer.erl:595: :timer.tc/2
```
