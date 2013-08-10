# -*- coding: utf-8 -*-

import json
from classifier import SoftConfidenceWeighted


def main():
    scw = SoftConfidenceWeighted()

    while(1):
        line = raw_input()
        if line == '':
            break

        obj = json.loads(line)
        if len(obj) != 2:
            print '[USAGE] [label, {feature:weight,...}]'

        if obj[0] == 0:
            obj[0] = scw.classify(obj[1])
            print 'classify:{0}'.format(json.dumps(obj))
        else:
            scw.update(obj[1], obj[0])
            print 'update:{0}'.format(json.dumps(obj))

if __name__ == "__main__":
    main()
