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

-----------------

```crystal
POST /:engine_id/upload?input_size=INPUT_SIZE&output_size=OUTPUT_SIZE
```

Upload a CSV file containing one row per data item, of `INPUT_SIZE` columns, resulting output
in the last `OUTPUT_SIZE` columns. Once your CSV file is successfully processed, you will get a token.

-----------------

```crystal
PATCH /:engine_id/upload?input_size=INPUT_SIZE&output_size=OUTPUT_SIZE&token=TOKEN
```

Append your training data with a CSV file containing one row per data item, of `INPUT_SIZE` columns, resulting output
in the last `OUTPUT_SIZE` columns. You must provide the creation `TOKEN` as query parameter.

-----------------

```crystal
PUT /:engine_id/upload?input_size=INPUT_SIZE&output_size=OUTPUT_SIZE&token=TOKEN
```

Replace your training data with a CSV file containing one row per data item, of `INPUT_SIZE` columns, resulting output
in the last `OUTPUT_SIZE` columns. You must provide the creation `TOKEN` as query parameter.

-----------------

```crystal
GET /:engine_id/run?value=VALUE
```

Run your engine with your `VALUE`.

-----------------

```crystal
GET /:engine_id/classifiy?value=VALUE&categories=CATEGORIES
```

Classify your `VALUE` in the `CATEGORIES` you provided.


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
