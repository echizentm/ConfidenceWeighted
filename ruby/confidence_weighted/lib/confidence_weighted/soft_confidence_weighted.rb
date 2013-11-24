module ConfidenceWeighted
  # Soft Confidence Weighted classifier
  class SoftConfidenceWeighted

    MIN_CONFIDENCE         = 0.0
    MAX_CONFIDENCE         = 1.0
    DEFAULT_CONFIDENCE     = 0.7
    MIN_AGGRESSIVENESS     = 0.0
    DEFAULT_AGGRESSIVENESS = 1.0
    VALID_LABEL            = [1, -1]
    ERF_ORDER              = 30

    def initialize(confidence: DEFAULT_CONFIDENCE, aggressiveness: DEFAULT_AGGRESSIVENESS)

      if confidence < MIN_CONFIDENCE
        confidence = MIN_CONFIDENCE
      elsif confidence > MAX_CONFIDENCE
        confidence = MAX_CONFIDENCE
      end

      if aggressiveness < MIN_AGGRESSIVENESS
        aggressiveness = MIN_AGGRESSIVENESS
      end

      @aggressiveness = aggressiveness
      @phi = probit(confidence)
      @psi = 1.0 + @phi * @phi / 2.0
      @zeta = 1.0 + @phi * @phi

      @mu = Hash.new(0.0)
      @sigma = Hash.new(1.0)
    end

    def classify(data)
      margin = 0.0
      data.each do |feature, weight|
        margin += @mu[feature] * weight if @mu.key?(feature)
      end
      return 1 if margin > 0
      -1
    end

    def update(data, label)
      return false unless VALID_LABEL.include?(label)

      sigma_x = get_sigma_x(data)
      margin_mean, variance = get_margin_mean_and_variance(label, data, sigma_x)

      return true if @phi * Math.sqrt(variance) <= margin_mean

      alpha, beta = get_alpha_and_beta(margin_mean, variance)
      return true if alpha == 0.0 || beta == 0.0

      sigma_x.each do |feature, weight|
        @mu[feature] += alpha * label * weight
        @sigma[feature] -= beta * weight * weight
      end

      true
    end

    private

    def get_sigma_x(data)
      sigma_x = Hash.new(1.0)
      data.each do |feature, weight|
        sigma_x[feature] *= @sigma[feature] * weight
      end
      sigma_x
    end

    def get_margin_mean_and_variance(label, data, sigma_x)
      margin_mean = 0.0
      variance    = 0.0
      data.each do |feature, weight|
        margin_mean += @mu[feature] * weight
        variance    += sigma_x[feature] * weight
      end
      [margin_mean * label, variance]
    end

    def get_alpha_and_beta(margin_mean, variance)
      alpha_den = variance * @zeta
      return [0.0, 0.0] if alpha_den == 0.0

      term1 = margin_mean * @phi / 2.0
      alpha = (-1.0 * margin_mean * @psi + @phi * Math.sqrt(term1 * term1 + alpha_den)) / alpha_den
      return [0.0, 0.0] if alpha <= 0.0

      alpha = @aggressiveness if alpha >= @aggressiveness

      beta_num = alpha * @phi
      term2    = variance * beta_num
      beta_den = term2 + ( -1.0 * term2 + Math.sqrt(term2 * term2 + 4.0 * variance)) / 2.0
      return [0.0, 0.0] if beta_den == 0.0

      [alpha, beta_num / beta_den]
    end

    def probit(p)
      Math.sqrt(2.0) * erf_inv(2.0 * p - 1.0)
    end

    def erf_inv(z)
      value = 1.0
      term  = 1.0
      c_memo = [1.0]

      (1.. ERF_ORDER).each do |n|
        term *= Math::PI * z * z / 4.0
        c = 0.0
        (0...n).each do |m|
          c += c_memo[m] * c_memo[n - 1 - m] / (m + 1.0) / (2.0 * m + 1.0)
        end
        c_memo << c
        value += c * term / (2.0 * n + 1.0)
      end
      Math.sqrt(Math::PI) * z * value / 2.0
    end
  end
end
