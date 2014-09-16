require ([
    "cosh/coffee-script",
    "cosh/marked",
    "cosh/pprint",
    "cosh/jss",
    "cosh/sourcemap/source-map-consumer" ],
    function(coffee, marked, pprint, jss, smc) {

        Object.extend()

        var $brand     = jQuery("#brand")
        var launchCode = location.hash.slice(1)
        var coshSource = localStorage.getItem("coshSource")
        var lastBuilt  = Date.create(localStorage.getItem("coshBuilt"))

        var stale = (
            !!! coshSource                       ||
            !!! lastBuilt                        ||
            launchCode == "build"                ||
            launchCode == "safemode"             ||
            lastBuilt < Date.create("12 hours ago")
            )

        if (!stale) return eval(coshSource)

        $brand.text("building...")

        jQuery.ajax({
            cache: false,
            url: "/scripts/main.coffee.md",
            success: function (main) {
                var options = {bare: true, literate: true}
                var js = coffee.compile(main, options)
                localStorage.setItem("coshSource", js)
                localStorage.setItem("coshBuilt", new Date().toString())
                eval(js)
                }})})
