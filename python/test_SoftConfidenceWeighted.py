# -*- coding: utf-8 -*-

from classifier import SoftConfidenceWeighted


class TestSoftConfidenceWeighted(object):
    def test_classify(self):
        assert SoftConfidenceWeighted().classify({}) == -1

    def test_update_invalid_label(self):
        assert not SoftConfidenceWeighted().update({}, -2)
        assert not SoftConfidenceWeighted().update({}, 0)
        assert not SoftConfidenceWeighted().update({}, 2)

    def test_update_ok(self):
        assert SoftConfidenceWeighted().update({}, -1)
        assert SoftConfidenceWeighted().update({}, 1)
