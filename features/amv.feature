@amvService
Feature: Amvs services
    Test complies for amv service

Scenario Outline: Test complies requirements
    Given That I want to call the amv service
    And I should test complies with Amode <a_mode> and Tmode <t_mode> and Vmode <v_mode> and Amodel <a_model> and Tmodel <t_model> and Vmodel <v_model> and IsRegulator <is_regulator> and the Result is <result>

Examples:
    | a_mode | t_mode | v_mode | a_model | t_model | v_model | is_regulator | result |
    | 0      | 0      | 0      | 1       | 1       | 1       | 0            | true   |
    | 0      | 0      | 0      | 1       | 1       | 1       | 1            | true   |
    | 0      | 0      | 0      | 1       | 1       | 2       | 0            | true   |
    | 0      | 0      | 0      | 1       | 1       | 2       | 1            | true   |
    | 0      | 0      | 0      | 1       | 2       | 3       | 0            | true   |
    | 0      | 0      | 0      | 1       | 2       | 3       | 1            | true   |

    | 0      | 0      | 1      | 1       | 1       | 1       | 0            | false  |
    | 0      | 0      | 1      | 1       | 1       | 1       | 1            | false  |
    | 0      | 0      | 1      | 1       | 1       | 2       | 0            | false  |
    | 0      | 0      | 1      | 1       | 1       | 2       | 1            | false  |
    | 0      | 0      | 1      | 1       | 2       | 3       | 0            | false  |
    | 0      | 0      | 1      | 1       | 2       | 3       | 1            | false  |

    | 0      | 1      | 0      | 1       | 1       | 1       | 0            | false  |
    | 0      | 1      | 0      | 1       | 1       | 1       | 1            | false  |
    | 0      | 1      | 0      | 1       | 1       | 2       | 0            | false  |
    | 0      | 1      | 0      | 1       | 1       | 2       | 1            | false  |
    | 0      | 1      | 0      | 1       | 2       | 3       | 0            | false  |
    | 0      | 1      | 0      | 1       | 2       | 3       | 1            | false  |

    | 1      | 0      | 0      | 1       | 1       | 1       | 0            | true   |
    | 1      | 0      | 0      | 1       | 1       | 1       | 1            | false  |
    | 1      | 0      | 0      | 1       | 1       | 2       | 0            | true   |
    | 1      | 0      | 0      | 1       | 1       | 2       | 1            | false  |
    | 1      | 0      | 0      | 1       | 2       | 3       | 0            | true   |
    | 1      | 0      | 0      | 1       | 2       | 3       | 1            | false  |

    | 1      | 1      | 0      | 1       | 1       | 1       | 0            | true   |
    | 1      | 1      | 0      | 1       | 1       | 1       | 1            | false  |
    | 1      | 1      | 0      | 1       | 1       | 2       | 0            | true   |
    | 1      | 1      | 0      | 1       | 1       | 2       | 1            | false  |
    | 1      | 1      | 0      | 1       | 2       | 3       | 0            | true   |
    | 1      | 1      | 0      | 1       | 2       | 3       | 1            | false  |

    | 1      | 0      | 1      | 1       | 1       | 1       | 0            | true   |
    | 1      | 0      | 1      | 1       | 1       | 1       | 1            | false  |
    | 1      | 0      | 1      | 1       | 1       | 2       | 0            | true   |
    | 1      | 0      | 1      | 1       | 1       | 2       | 1            | false  |
    | 1      | 0      | 1      | 1       | 2       | 3       | 0            | true   |
    | 1      | 0      | 1      | 1       | 2       | 3       | 1            | false  |

    | 0      | 1      | 1      | 1       | 1       | 1       | 0            | false  |
    | 0      | 1      | 1      | 1       | 1       | 1       | 1            | false  |
    | 0      | 1      | 1      | 1       | 1       | 2       | 0            | false  |
    | 0      | 1      | 1      | 1       | 1       | 2       | 1            | false  |
    | 0      | 1      | 1      | 1       | 2       | 3       | 0            | false  |
    | 0      | 1      | 1      | 1       | 2       | 3       | 1            | false  |

    | 1      | 1      | 1      | 1       | 1       | 1       | 0            | true   |
    | 1      | 1      | 1      | 1       | 1       | 1       | 1            | true   |
    | 1      | 1      | 1      | 1       | 1       | 2       | 0            | false  |
    | 1      | 1      | 1      | 1       | 1       | 2       | 1            | false  |
    | 1      | 1      | 1      | 1       | 2       | 3       | 0            | false  |
    | 1      | 1      | 1      | 1       | 2       | 3       | 1            | false  |
