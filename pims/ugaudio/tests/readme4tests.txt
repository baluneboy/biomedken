# change to tests directory, then use this for non-verbose testing
python -m unittest discover -s . -p 'test_*.py'

# change to tests directory, then use this for verbose testing
python -m unittest discover -s . -p 'test_*.py' -v
