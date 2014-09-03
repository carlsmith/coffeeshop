require ([
    "cosh/coffee-script",
    "cosh/marked",
    "cosh/pprint",
    "cosh/sourcemap/source-map-consumer"
    ],
    function(coffee, marked, pprint, smc) {

        Object.extend()

        var $brand = jQuery("#brand")
        var launchCode = location.hash.slice(1)
        var coshSource = localStorage.getItem("coshSource")
        var coshVersion = localStorage.getItem("coshVersion")

        var stale = (
            !coshSource                                         ||
            !coshVersion                                        ||
            launchCode in ["build", "safemode"]                 ||
            Date.create(coshVersion) < Date.create("12 hours ago")
            )

        if (!stale) return eval(coshSource)

        $brand.text("building...")
        jQuery.get("/scripts/main.coffee", function (main) {
            var js = coffee.compile(main, {bare: true})
            localStorage.setItem("coshSource", js)
            localStorage.setItem("coshVersion", new Date().toString())
            eval(js)
            })})
