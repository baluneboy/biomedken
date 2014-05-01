#!/usr/bin/env python

from pandas import DataFrame

l1 = [1,2,3,4]
l2 = [1,2,3,4]
df = DataFrame({'Stimulus Time': l1, 'Reaction Time': l2})
df
df.to_excel('/tmp/test.xlsx', sheet_name='kpi', index=False)
