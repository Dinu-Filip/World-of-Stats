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
      if (vals["x_1"] != "") {
        double x_1 = double.parse(vals["x_1"]!);
        if (x_1 < -20000 || x_1 > 20000) {
          return {
            "res": false,
            "msg": "Lower limit out of range",
            "fields": ["x_1"]
          };
        }
      }
      if (vals["x_2"] != "") {
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

  static Map<String, dynamic> chiSquared(Map<String, String> vals) {
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

  static Map<String, dynamic> dataAnalysis(Map<String, String> vals) {
    String delimiter = "";
    if (vals["typeData"] == "bivariate") {
      delimiter = vals["delimiter"]!;
    } else {
      delimiter = ",";
    }
    if (vals["inputType"] == "x, y list inputs" ||
        vals["inputType"] == "table input") {
      String yLbl = "";
      if (vals["typeData"] == "univariate") {
        yLbl = "frequency";
      } else {
        yLbl = "y";
      }

      String xVals = vals["xInput"]!;
      String yVals = vals["yInput"]!;
      if (xVals == "") {
        return {
          "res": false,
          "msg": "At least one x value must be entered",
          "fields": ["xInput"]
        };
      } else if (yVals == "") {
        return {
          "res": false,
          "msg": "At least one $yLbl value must be entered",
          "fields": ["yInput"]
        };
      }
      List<String> splitX = xVals.split(delimiter);
      List<String> splitY = yVals.split(delimiter);
      if (splitX.length != splitY.length) {
        return {
          "res": false,
          "msg": "There must be the same number of x and $yLbl values",
          "fields": ["xInput", "yInput"]
        };
      } else if (splitX.length > 50) {
        return {
          "res": false,
          "msg": "Maximum of 50 values can be inputted",
          "fields": ["xInput", "yInput"]
        };
      }
      for (int i = 0; i < splitX.length; i++) {
        if (double.tryParse(splitX[i]) == null) {
          return {
            "res": false,
            "msg": "${xVals[i]} is not a valid decimal",
            "fields": ["xInput"]
          };
        } else if (vals["typeData"] == "bivariate" &&
            double.tryParse(splitY[i]) == null) {
          return {
            "res": false,
            "msg": "${yVals[i]} is not a valid decimal",
            "fields": ["yInput"]
          };
        } else if (vals["typeData"] == "univariate" &&
            int.tryParse(splitY[i]) == null) {
          return {
            "res": false,
            "msg": "${yVals[i]} is not a valid integer",
            "fields": ["yInput"]
          };
        }
        double x = double.parse(splitX[i]);
        double y = double.parse(splitY[i]);
        if (x < -10000 || x > 10000) {
          return {
            "res": false,
            "msg": "${splitX[i]} is out of range",
            "fields": ["xInput"]
          };
        } else if (y < -10000 || y > 10000) {
          return {
            "res": false,
            "msg": "${splitY[i]} is out of range",
            "fields": ["yInput"]
          };
        }
      }
    } else if (vals["inputType"] == "(x, y) pairs") {
      if (vals["dataInput"] == "") {
        return {
          "res": false,
          "msg": "At least one point must be inputted",
          "fields": ["dataInput"]
        };
      }
      List<String> points = vals["dataInput"]!.split(delimiter);
      if (vals["typeData"] == "bivariate") {
        for (String point in points) {
          String strippedPoint = point.substring(1, point.length - 1);
          List<String> xy = strippedPoint.split(", ");
          if (double.tryParse(xy[0]) == null) {
            return {
              "res": false,
              "msg": "${xy[0]} in $point is not a valid decimal",
              "fields": ["dataInput"]
            };
          } else if (double.tryParse(xy[1]) == null) {
            return {
              "res": false,
              "msg": "${xy[1]} in $point is not a valid decimal",
              "fields": ["dataInput"]
            };
          }
        }
      } else {
        for (String point in points) {
          if (double.tryParse(point) == null) {
            return {
              "res": false,
              "msg": "$point is not a valid decimal",
              "fields": ["dataInput"]
            };
          }
        }
      }
    }
    return {"res": true};
  }

  static Map<String, dynamic> sigLevel(String sigLevel) {
    double sig = double.parse(sigLevel);
    if (sig <= 0) {
      return {
        "res": false,
        "msg": "The significance level must be positive",
        "fields": ["sig_level"]
      };
    } else if (sig >= 50) {
      return {
        "res": false,
        "msg": "The significance level must be less than 50%",
        "fields": ["sig_level"]
      };
    } else {
      return {"res": true};
    }
  }

  static Map<String, dynamic> binomialHT(Map<String, String> submittedVals) {
    if (int.tryParse(submittedVals["num_trials"]!) == null) {
      return {
        "res": false,
        "msg": "Number of trials must be valid integer",
        "fields": ["n"]
      };
    } else if (double.tryParse(submittedVals["prob"]!) == null) {
      return {
        "res": false,
        "msg":
            "Probability of success of the population must be a valid decimal",
        "fields": "p"
      };
    } else if (int.tryParse(submittedVals["X"]!) == null) {
      return {
        "res": false,
        "msg": "Number of successes in the sample must be a valid integer",
        "fields": "X"
      };
    } else if (double.tryParse(submittedVals["sig_level"]!) == null) {
      return {
        "res": false,
        "msg": "The significance level must be a valid decimal",
        "fields": "sig_level"
      };
    } else {
      int n = int.parse(submittedVals["num_trials"]!);
      if (n < 0) {
        return {
          "res": false,
          "msg": "Number of successes must be positive",
          "fields": "n"
        };
      } else if (n > 10000) {
        return {
          "res": false,
          "msg": "Number of successes out of range",
          "fields": "n"
        };
      }
      double p = double.parse(submittedVals["prob"]!);
      if (p <= 0) {
        return {
          "res": false,
          "msg": "Probability of success of population must be positive",
          "fields": ["p"]
        };
      } else if (p > 1) {
        return {
          "res": false,
          "msg": "Probability of success cannot be greater than 1",
          "fields": ["p"]
        };
      }
      int X = int.parse(submittedVals["X"]!);
      if (X < 0) {
        return {
          "res": false,
          "msg": "The number of successes in the sample must be positive",
          "fields": ["X"]
        };
      } else if (X > n) {
        return {
          "res": false,
          "msg":
              "The number of successes in the sample cannot be greater than the total number of trials",
          "fields": ["X"]
        };
      }
      Map<String, dynamic> sigRes =
          Validation.sigLevel(submittedVals["sig_level"]!);
      if (!sigRes["res"]) {
        return sigRes;
      }
      return {"res": true};
    }
  }

  static Map<String, dynamic> normalHT(Map<String, String> submittedVals) {
    if (double.tryParse(submittedVals["sample_mean"]!) == null) {
      return {
        "res": false,
        "msg": "The sample mean must be a valid decimal",
        "fields": ["sample_mean"]
      };
    } else if (double.tryParse(submittedVals["population_mean"]!) == null) {
      return {
        "res": false,
        "msg": "The mean of the population must be a valid decimal",
        "fields": ["population_mean"]
      };
    } else if (double.tryParse(submittedVals["sd"]!) == null) {
      return {
        "res": false,
        "msg":
            "The standard deviation of the population must be a valid decimal",
        "fields": ["population_sd"]
      };
    } else if (int.tryParse(submittedVals["N"]!) == null) {
      return {
        "res": false,
        "msg": "The sample size must be a valid integer",
        "fields": ["sample_size"]
      };
    } else if (double.tryParse(submittedVals["sig_level"]!) == null) {
      return {
        "res": false,
        "msg": "The significance level must be a valid decimal",
        "fields": ["sig_level"]
      };
    } else {
      double sampleMean = double.parse(submittedVals["sample_mean"]!);
      double populationMean = double.parse(submittedVals["population_mean"]!);
      double populationSd = double.parse(submittedVals["sd"]!);
      Map<String, dynamic> sigRes =
          Validation.sigLevel(submittedVals["sig_level"]!);
      if (populationMean < -100000 || populationMean > 100000) {
        return {
          "res": false,
          "msg": "Population mean out of range",
          "fields": ["population_mean"]
        };
      } else if (sampleMean < populationMean - 10 * populationSd ||
          sampleMean > populationMean + 10 * populationSd) {
        return {
          "res": false,
          "msg": "Sample mean out of range",
          "fields": ["sample_mean"]
        };
      } else if (populationSd <= 0) {
        return {
          "res": false,
          "msg": "Population standard deviation out of range",
          "fields": ["population_sd"]
        };
      } else if (!sigRes["res"]) {
        return sigRes;
      } else {
        return {"res": true};
      }
    }
  }

  static Map<String, dynamic> goodnessOfFit(Map<String, String> submittedVals) {
    String delimiter = submittedVals["delimiter"]!;
    List<String> xVals = submittedVals["xVals"]!.split(delimiter);
    List<String> expectedVals = submittedVals["observedVals"]!.split(delimiter);
    for (String num in xVals) {
      if (double.tryParse(num) == null) {
        return {
          "res": false,
          "msg": "Invalid input in x values field ($num)",
          "fields": ["xVals"]
        };
      }
    }
    for (String num in expectedVals) {
      if (double.tryParse(num) == null) {
        return {
          "res": false,
          "msg": "Invalid input in expected values field ($num)",
          "fields": ["expectedVals"]
        };
      }
    }
    if (xVals.length != expectedVals.length) {
      return {
        "res": false,
        "msg":
            "Number of x values must be the same as number of expected values",
        "fields": ["expectedVals", "xVals"]
      };
    }
    switch (submittedVals["distribution"]) {
      case "binomial":
        return Validation.GOFBinomial(submittedVals);
      default:
        return {"res": true};
    }
  }

  static Map<String, dynamic> GOFBinomial(submittedVals) {
    String n = submittedVals["n"];
    String p = submittedVals["p"];
    if (int.tryParse(n) == null) {
      return {
        "res": false,
        "msg": "Number of trials must be a valid integer",
        "fields": ["n"]
      };
    } else if (double.tryParse(p) == null) {
      return {
        "res": false,
        "msg": "Probability of success must be a valid decimal",
        "fields": ["p"]
      };
    }
    int nVal = int.parse(n);
    double pVal = double.parse(p);
    if (pVal <= 0 || pVal > 1) {
      return {
        "res": false,
        "msg": "Probability of success must be between 0 and 1",
        "fields": ["p"]
      };
    } else if (nVal <= 0) {
      return {
        "res": false,
        "msg": "Number of trials must be positive",
        "fields": ["n"]
      };
    } else if (nVal > 10000) {
      return {
        "res": false,
        "msg": "Number of trials out of range",
        "fields": ["n"]
      };
    }
    return {"res": true};
  }
}
