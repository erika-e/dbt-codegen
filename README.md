# dbt-codegen

Macros that generate dbt code, and log it to the command line.

# Contents
* [generate_source](#generate_source-source)
* [generate_base_model](#generate_base_model-source)
* [generate_model_yaml](#generate_model_yaml-source)
* [generate_snapshot](#generate_snapshot-source)

# Installation instructions
New to dbt packages? Read more about them [here](https://docs.getdbt.com/docs/building-a-dbt-project/package-management/).
1. Include this package in your `packages.yml` file — check [here](https://hub.getdbt.com/dbt-labs/codegen/latest/) for the latest version number.
2. Run `dbt deps` to install the package.

# Macros
## generate_source ([source](macros/generate_source.sql))
This macro generates lightweight YAML for a [Source](https://docs.getdbt.com/docs/using-sources),
which you can then paste into a schema file.

### Arguments
* `schema_name` (required): The schema name that contains your source data
* `database_name` (optional, default=target.database): The database that your
source data is in.
* `generate_columns` (optional, default=False): Whether you want to add the
column names to your source definition.
* `include_descriptions` (optional, default=False): Whether you want to add 
description placeholders to your source definition.

### Usage:
1. Copy the macro into a statement tab in the dbt Cloud IDE, or into an analysis file, and compile your code

```
{{ codegen.generate_source('raw_jaffle_shop') }}
```

Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):

```
$ dbt run-operation generate_source --args 'schema_name: raw_jaffle_shop'
```

or

```
# for multiple arguments, use the dict syntax
$ dbt run-operation generate_source --args '{"schema_name": "jaffle_shop", "database_name": "raw"}'
```

2. The YAML for the source will be logged to the command line

```
version: 2

sources:
  - name: raw_jaffle_shop
    database: raw
    tables:
      - name: customers
        description: ""
      - name: orders
        description: ""
      - name: payments
        description: ""
```

3. Paste the output in to a schema `.yml` file, and refactor as required.

## generate_base_model ([source](macros/generate_base_model.sql))
This macro generates the SQL for a base model, which you can then paste into a
model.

### Arguments:
* `source_name` (required): The source you wish to generate base model SQL for.
* `table_name` (required): The source table you wish to generate base model SQL for.
* `leading_commas` (optional, default=False): Whether you want your commas to be leading (vs trailing).


### Usage:
1. Create a source for the table you wish to create a base model on top of.
2. Copy the macro into a statement tab in the dbt Cloud IDE, or into an analysis file, and compile your code

```
{{ codegen.generate_base_model(
    source_name='raw_jaffle_shop',
    table_name='customers'
) }}
```

Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):

```
$ dbt run-operation generate_base_model --args '{"source_name": "raw_jaffle_shop", "table_name": "customers"}'
```

3. The SQL for a base model will be logged to the command line

```
with source as (

    select * from {{ source('raw_jaffle_shop', 'customers') }}

),

renamed as (

    select
        id,
        first_name,
        last_name,
        email,
        _elt_updated_at

    from source

)

select * from renamed
```

4. Paste the output in to a model, and refactor as required.

## generate_model_yaml ([source](macros/generate_model_yaml.sql))
This macro generates the YAML for a model, which you can then paste into a
schema.yml file.

### Arguments:
* `model_name` (required): The model you wish to generate YAML for.

### Usage:
1. Create a model.
2. Copy the macro into a statement tab in the dbt Cloud IDE, or into an analysis file, and compile your code

```
{{ codegen.generate_model_yaml(
    model_name='customers'
) }}
```

Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):

```
$ dbt run-operation generate_model_yaml --args '{"model_name": "customers"}'
```

3. The YAML for a base model will be logged to the command line

```
version: 2

models:
  - name: customers
    columns:
      - name: customer_id
        description: ""
      - name: customer_name
        description: ""
```

4. Paste the output in to a schema.yml file, and refactor as required.

## generate_snapshot ([source](macros/generate_snapshot.sql))
This macro generates the SQL for a snapshot, which you can then paste into a
model.

### Arguements
* `snapshot_name` (required): The name of the table dbt creates for the snapshot.
* `source_name` (required): The source you wish snapshot.
* `table_name` (required): The source table you wish to snapshot.
* `strategy` (optional): Defaults to timestamp which is the dbt recommended strategy. Use `check_cols` for the check_cols strategy.
* `target_schema` (optional): Defaults to snapshots
* `optional_args` (optional): Adds the two optional snapshot-specific configurations

### Usage:
1. Create a model.
2. Copy the macro into a statement tab in the dbt Cloud IDE, or into an analysis file, and compile your code

```
{{ codegen.generate_snapshot(
    snapshot_name='customers_snapshot',
    source_name='raw_jaffle_shop',
    table_name='customers'
) }}
```

Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):

```
$ dbt run-operation generate_snapshot --args '{"snapshot_name": "customers_snapshot", "source_name":"raw_jaffle_shop", "table_name":"customers"}'
```

3. The SQL for the snapshot model will be logged to the command line 

```
{{
    config(

        target_schema='snapshots',
        strategy='timestamp',
        updated_at = "",
        unique_key = "",
        
    )
}}


{% snapshot customers_snapshot %}

    select * from {{ source('raw_jaffle_shop', 'customers') }}

{% endsnapshot %} 
```

4. Paste the output into a sql file in your snapshots directory and refactor as required.

Note that you must populate the `unique_key` column and the column required by the strategy you have chosen -- `updated_at` for timestamp or `check_cols` for the `check` strategy.