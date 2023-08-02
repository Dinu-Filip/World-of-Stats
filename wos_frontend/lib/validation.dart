class Validation {
  static Map<String, dynamic> binomial(Map<String, String> vals) {
    if (int.tryParse(vals["n"]!) == null) {
      return {
        "res": false,
        "msg": "The number of trials must be a valid integer",
        "fields": ["n"]
      };
    } else if (double.tryParse(vals["p"]!) == null) {
      return {
        "res": false,
        "msg": "The probability of success must be a valid decimal",
        "fields": ["p"]
      };
    } else {
      int n = int.parse(vals["n"]!);
      double p = double.parse(vals["p"]!);
      if (n <= 0) {
        return {
          "res": false,
          "msg": "The number of trials must be positive",
          "fields": ["n"]
        };
      } else if (n >= 10000) {
        return {
          "res": false,
          "msg": "Out of range",
          "fields": ["n"]
        };
      } else if (p <= 0) {
        return {
          "res": false,
          "msg": "Probability of success must be positive",
          "fields": ["p"]
        };
      } else if (p >= 1) {
        return {
          "res": false,
          "msg": "Probability of success must be less than one",
          "fields": ["p"]
        };
      }
    }
    int n = int.parse(vals["n"]!);
    if (vals.keys.toList().contains("x")) {
      if (int.tryParse(vals["x"]!) == null) {
        return {
          "res": false,
          "msg": "The random variable must be an integer",
          "fields": ["x"]
        };
      } else {
        int x = int.parse(vals["x"]!);
        if (x <= 0) {
          return {
            "res": false,
            "msg": "The random variable must be positive",
            "fields": ["x"]
          };
        } else if (x > n) {
          return {
            "res": false,
            "msg":
                "The random variable cannot be greater than the number of trials",
            "fields": ["x", "n"]
          };
        }
      }
    } else if (vals.keys.toList().contains("x_1")) {
      if (vals["x_1"] == "" && vals["x_2"] == "") {
        return {
          "res": false,
          "msg": "At least one limit for the probability region must be given"
        };
      } else if (vals["x_1"] != "" && int.tryParse(vals["x_1"]!) == null) {
        return {
          "res": false,
          "msg": "Lower limit must be a valid integer",
          "fields": ["x_1"]
        };
      } else if (vals["x_2"] != "" && int.tryParse(vals["x_2"]!) == null) {
        return {
          "res": false,
          "msg": "Upper limit must be a valid integer",
          "fields": ["x_2"]
        };
      }
      if (vals["x_1"]! != "") {
        int x_1 = int.parse(vals["x_1"]!);
        if (vals["x_2"] != "") {
          if (x_1 >= int.parse(vals["x_2"]!)) {
            return {
              "res": false,
              "msg": "Lower limit must be smaller than or equal to upper limit",
              "fields": ["x_1", "x_2"]
            };
          }
        }
        if (x_1 < 0 || x_1 > n) {
          return {
            "res": false,
            "msg": "Lower limit out of range",
            "fields": ["x_1", "n"]
          };
        }
      }
      if (vals["x_2"]! != "") {
        int x_2 = int.parse(vals["x_2"]!);
        if (x_2 < 0 || x_2 > n) {
          return {
            "res": false,
            "msg": "Upeer limit out of range",
            "fields": ["x_2", "n"]
          };
        }
      }
    } else if (vals.keys.toList().contains("P")) {
      if (double.tryParse(vals["P"]!) == null) {
        return {
          "res": false,
          "msg": "Probability must be a valid decimal",
          "fields": ["P"]
        };
      } else {
        double P = double.parse(vals["P"]!);
        if (P <= 0) {
          return {
            "res": false,
            "msg": "Probability must be positive",
            "fields": ["P"]
          };
        } else if (P > 1) {
          return {
            "res": false,
            "msg": "Probability cannot be greater than one",
            "fields": ["P"]
          };
        }
      }
    }
    return {"res": true};
  }

  static Map<String, dynamic> normal(Map<String, String> vals) {
    if (double.tryParse(vals["mu"]!) == null) {
      return {
        "res": false,
        "msg": "Mean must be a valid decimal",
        "fields": ["mu"]
      };
    } else if (double.tryParse(vals["sigma"]!) == null) {
      return {
        "res": false,
        "msg": "Standard deviation must be a valid decimal",
        "fields": ["sigma"]
      };
    } else {
      double mu = double.parse(vals["mu"]!);
      double sigma = double.parse(vals["sigma"]!);
      if (mu < -10000 || mu > 10000) {
        return {
          "res": false,
          "msg": "Mean out of range",
          "fields": ["mu"]
        };
      } else if (sigma < -1000 || sigma > 1000) {
        return {
          "res": false,
          "msg": "Standard deviation out of range",
          "fields": ["sigma"]
        };
      }
    }
    if (vals.keys.toList().contains("x_1")) {
      if (vals["x_1"] == "" && vals["x_2"] == "") {
        return {
          "res": false,
          "msg": "At least one limit for probability region must be given"
        };
      } else if (vals["x_1"] != "" && double.tryParse(vals["x_1"]!) == null) {
        return {
          "res": false,
          "msg": "Lower limit must be a valid decimal",
          "fields": ["x_1"]
        };
      } else if (vals["x_2"] != "" && double.tryParse(vals["x_2"]!) == null) {
        return {
          "res": false,
          "msg": "Upper limit must be a valid decimal",
          "fields": ["x_2"]
        };
      }
      if (vals["x_1"] != null) {
        double x_1 = double.parse(vals["x_1"]!);
        if (x_1 < -20000 || x_1 > 20000) {
          return {
            "res": false,
            "msg": "Lower limit out of range",
            "fields": ["x_1"]
          };
        }
      }
      if (vals["x_2"] != null) {
        double x_2 = double.parse(vals["x_2"]!);
        if (x_2 < -20000 || x_2 > 20000) {
          return {
            "res": false,
            "msg": "Upper limit out of range",
            "fields": ["x_2"]
          };
        }
      }
    } else {
      if (double.tryParse(vals["P"]!) == null) {
        return {
          "res": false,
          "msg": "Probability must be a valid decimal",
          "fields": ["P"]
        };
      } else {
        double P = double.parse(vals["P"]!);
        if (P <= 0) {
          return {
            "res": false,
            "msg": "Probability must be positive",
            "fields": ["P"]
          };
        } else if (P > 1) {
          return {
            "res": false,
            "msg": "Probability must be positive",
            "fields": ["P"]
          };
        }
      }
    }
    return {"res": true};
  }

  Map<String, dynamic> chiSquared(Map<String, String> vals) {
    if (int.tryParse(vals["df"]!) == null) {
      return {
        "res": false,
        "msg": "Degrees of freedom must be a valid integer",
        "fields": ["df"]
      };
    } else {
      int df = int.parse(vals["df"]!);
      if (df <= 0) {
        return {
          "res": false,
          "msg": "Degrees of freedom must be positive",
          "fields": ["df"]
        };
      } else if (df > 1000) {
        return {
          "res": false,
          "msg": "Degrees of freedom out of range",
          "fields": ["df"]
        };
      }
    }
    if (vals.keys.toList().contains("x")) {
      if (double.tryParse(vals["x"]!) == null) {
        return {
          "res": false,
          "msg": "Random variable must be a valid decimal",
          "fields": ["x"]
        };
      } else {
        double x = double.parse(vals["x"]!);
        if (x < 0) {
          return {
            "res": false,
            "msg": "Random variable must be nonnegative",
            "fields": ["x"]
          };
        } else if (x >= 10000) {
          return {
            "res": false,
            "msg": "Random variable out of range",
            "fields": ["x"]
          };
        }
      }
    } else if (vals.keys.toList().contains("x_1")) {
      if (vals["x_1"] == "" && vals["x_2"] == "") {
        return {"res": false, "msg": "At least one limit must be given"};
      } else if (vals["x_1"] != "" && double.tryParse(vals["x_1"]!) == null) {
        return {
          "res": false,
          "msg": "Lower limit must be a valid decimal",
          "fields": ["x_1"]
        };
      } else if (vals["x_2"] != "" && double.tryParse(vals["x_2"]!) == null) {
        return {
          "res": false,
          "msg": "Upper limit must be a valid decimal",
          "fields": ["x_2"]
        };
      } else {
        if (vals["x_1"] != "") {
          double x_1 = double.parse(vals["x_1"]!);
          if (x_1 < 0 || x_1 > 10000) {
            return {
              "res": false,
              "msg": "Lower limit out of range",
              "fields": ["x_1"]
            };
          }
        }
        if (vals["x_2"] != "") {
          double x_2 = double.parse(vals["x_2"]!);
          if (x_2 < 0 || x_2 > 10000) {
            return {
              "res": false,
              "msg": "Upper limit out of range",
              "fields": ["x_2"]
            };
          }
        }
      }
    } else {
      if (double.tryParse(vals["P"]!) == null) {
        return {
          "res": false,
          "msg": "Probability must be a valid decimal",
          "fields": ["P"]
        };
      } else {
        double P = double.parse(vals["P"]!);
        if (P <= 0) {
          return {
            "res": false,
            "msg": "Probability must be positive",
            "fields": ["P"]
          };
        } else if (P > 1) {
          return {
            "res": false,
            "msg": "Probability must be positive",
            "fields": ["P"]
          };
        }
      }
    }
    return {"res": true};
  }
}
