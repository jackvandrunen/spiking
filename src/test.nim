import ./neuron
import ./synapse


proc testOne(ts: int): tuple[a: seq[float], b: seq[float]] =
    # two RS neurons joined by an AMPA synapse, with constant current applied to the first
    # ts is the duration in timesteps
    # returns two lists: the voltages of each neuron at each timestep
    var neuronA: Neuron = (
        V_n: -1.0,
        I_n: -2.9,  # ("y" value of -2.9 in RTB, Figs. 3 and 5 is for FS neurons, not sure what the initial value would be for RS, or how much it matters)
        V_n1: -1.0,
        spike: false
    )
    var neuronB: Neuron = (
        V_n: -1.0,
        I_n: -2.9,
        V_n1: -1.0,
        spike: false
    )
    var synapse: Synapse = (
        V_rp: 0.0,
        gamma: 0.97,
        w: 1.0,
        g: 0.5,
        I_syn: 0.0  # initial value shouldn't matter because it gets reset every timestep
    )
    const externalCurrent = 1.0  # apply constant external current

    for t in 1 .. ts:
        neuronA = step(neuronA, externalCurrent)
        synapse = step(synapse, neuronA.spike, neuronB.V_n)
        neuronB = step(neuronB, synapse.I_syn)

        result.a.add(neuronA.V_n)
        result.b.add(neuronB.V_n)


when isMainModule:
    import json

    let testOneResults = testOne(100)

    writeFile("testOneResults.json", $(%[testOneResults.a, testOneResults.b]))
