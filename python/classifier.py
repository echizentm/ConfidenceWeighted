# -*- coding: utf-8 -*-

from math import sqrt, pi


class SoftConfidenceWeighted(object):
    ERF_ORDER = 30
    DEFAULT_CONFIDENCE = 0.7
    DEFAULT_AGGRESSIVENESS = 1.0

    def __init__(self):
        self.aggressiveness = self.DEFAULT_AGGRESSIVENESS
        self.phi = self.__probit(self.DEFAULT_CONFIDENCE)

        self.psi = 1 + self.phi * self.phi / 2
        self.zeta = 1 + self.phi * self.phi

        self.mu = {}
        self.sigma = {}

    def classify(self, data):
        margin = 0
        for feature, weight in data.iteritems():
            if feature in self.mu:
                margin += self.mu[feature] * weight
        return 1 if margin > 0 else -1

    def update(self, data, label):
        if not (label in [1, -1]):
            return False

        sigma_x = self.__get_sigma_x(data)
        (mean, variance) = self.__get_margin_mean_and_variance(
            label, data, sigma_x)
        if (self.phi * sqrt(variance)) <= mean:
            return True

        (alpha, beta) = self.__get_alpha_and_beta(mean, variance)
        if alpha == 0 or beta == 0:
            return True

        for feature, weight in sigma_x.iteritems():
            self.mu[feature] += alpha * label * weight
            self.sigma[feature] -= beta * weight * weight
        return True

    def __get_sigma_x(self, data):
        sigma_x = {}
        for feature, weight in data.iteritems():
            if not feature in self.sigma:
                self.sigma[feature] = 1
            sigma_x[feature] = self.sigma[feature] * weight
        return sigma_x

    def __get_margin_mean_and_variance(self, label, data, sigma_x):
        mean = 0
        variance = 0
        for feature, weight in data.iteritems():
            if not feature in self.mu:
                self.mu[feature] = 0
            mean += self.mu[feature] * weight
            variance += sigma_x[feature] * weight
        mean *= label
        return mean, variance

    def __get_alpha_and_beta(self, mean, variance):
        alpha_den = variance * self.zeta
        if alpha_den == 0:
            return 0, 0

        term1 = mean * self.phi / 2
        alpha = (
            -1 * mean * self.psi +
            self.phi * sqrt(term1 * term1 + alpha_den)
        ) / alpha_den
        if alpha <= 0:
            return 0, 0

        if alpha >= self.aggressiveness:
            alpha = self.aggressiveness

        beta_num = alpha * self.phi
        term2 = variance * beta_num
        beta_den = term2 + (
            -1 * term2 + sqrt(term2 * term2 + 4 * variance)
        ) / 2
        if beta_den == 0:
            return 0, 0

        return alpha, beta_num / beta_den

    def __probit(self, p):
        return sqrt(2) * self.__erf_inv(2 * p - 1)

    def __erf_inv(self, z):
        value = 1
        term = 1
        c_memo = [1]
        for n in range(1, self.ERF_ORDER+1):
            term *= (pi * z * z / 4)
            c = 0
            for m in range(0, n):
                c += (c_memo[m] * c_memo[n - 1 - m] /
                     (m + 1) / (2 * m + 1))
            c_memo.append(c)
            value += (c * term / (2 * n + 1))
        return (sqrt(pi) * z * value / 2)
