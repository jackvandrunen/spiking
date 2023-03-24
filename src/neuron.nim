const
    beta_e = 0.133
    # sigma_e = 1.0
    sigma_1 = 1.06  # sigma + 1
    mu = 0.0005
    alpha = 3.65


type
    Neuron* = tuple
        V_n: float
        I_n: float
        V_n1: float  # V_{n-1}
        spike: bool


func checkSpike(V_n, V_n1, I_n: float): bool {.inline.} =
    0 < V_n and V_n < alpha + I_n and V_n1 <= 0


func f_alpha(V_n, V_n1, I_n: float): float =
    if V_n <= 0:
        alpha / (1.0 - V_n) + I_n
    elif checkSpike(V_n, V_n1, I_n):
        alpha + I_n
    else:
        -1.0


func step*(n: Neuron, I_ext: float): Neuron =
    (
        V_n: f_alpha(n.V_n, n.V_n1, n.I_n + beta_e * I_ext),
        I_n: n.I_n - mu * (n.V_n + I_ext + sigma_1),
        V_n1: n.V_n,
        spike: checkSpike(n.V_n, n.V_n1, n.I_n + beta_e * I_ext)
    )


proc step*(neurons: var openArray[Neuron], I_exts: openArray[float]) =
    for i, n in neurons:
        neurons[i] = step(n, I_exts[i])
