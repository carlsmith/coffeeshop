!function tick() {
    postMessage(new Date())
    setTimeout(tick, 1000)
    }()
