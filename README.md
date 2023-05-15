# Multiverse (Slug Edition)

## Getting Started

- Clone this repo.  It will have all the custom code required.
- Follow the directions for `multiverse` except for getting `capstone` and `elfmanip`

Find your python path by running in `python`
```
import sys
print(sys.path)
```
and find an appropriate place to symlink in `capstone` and `elfmanip`

For `capstone`, in the `capstone` directory, go to `bindings/python` and then run `python3 setup.py build`.
Then you can symlink with `ln -s $PWD/build/lib/capstone <localpythonpath>/capstone`.

`elfmanip` is similar.
From the `elfmanip` directory you build with `python3 setup.py build` and then simlink with `ln -s $PWD/elfmanip <localpythonpath>/elfmanip`

