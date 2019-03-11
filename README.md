# Learner

Basic Neural Network as a service, written in Crystal.

## Installation

Requires Crystal 0.27.0.

```
git clone git@github.com:suruja/learner.git
cd learner
shards install
```

## Usage

### Start

```
crystal run src/learner.cr
```

### API

Every value must be castable to `Float64`. Either input, output or category must be castable to a vector, aka `Array(Float64)`. Pass your query parameters in JSON format.

#### CRUD your engine

To create, replace or append your engine training data, you can either upload a CSV file (using `;` as separator) file containing one row per data item, of `INPUT_SIZE` columns, resulting output in the last `OUTPUT_SIZE` columns, or pass your JSON-encoded data in `data` query parameter.

```
POST /:engine_id?input_size=INPUT_SIZE&output_size=OUTPUT_SIZE
```

Create your engine. Once your data (CSV file or `data` query parameter) is successfully processed, you will get a token you must keep.

-----------------

```
PATCH /:engine_id?input_size=INPUT_SIZE&output_size=OUTPUT_SIZE&token=TOKEN
```

Append your engine training data, uploading CSV file or passing `data` query parameter. You must provide the creation `TOKEN` as query parameter.


-----------------

```
PUT /:engine_id?input_size=INPUT_SIZE&output_size=OUTPUT_SIZE&token=TOKEN
```

Replace your engine training data, uploading CSV file or passing `data` query parameter. You must provide the creation `TOKEN` as query parameter.

-----------------

```
DELETE /:engine_id?token=TOKEN
```

Destroy your engine. You must provide the creation `TOKEN` as query parameter.


#### Consume your engine

```
GET /:engine_id/run?value=VALUE
```

Run your engine with your `VALUE`.

-----------------

```
GET /:engine_id/classify?value=VALUE
```

Classify your `VALUE` among the categories found in your data.


## Specs

```
KEMAL_ENV=test crystal spec
```


## Contributing

1. Fork it (<https://github.com/suruja/learner/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [suruja](https://github.com/suruja) - creator and maintainer
