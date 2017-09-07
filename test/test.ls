require! \assert : {equal}

describe \Array ->
    describe '#indexOf()' ->
        specify 'should return -1 when the value is not present' ->
            equal(-1, [1 2 3].indexOf(4))
