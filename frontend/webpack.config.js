module.exports = [{
    entry: './src/index.js',
    output: {
        library: "CrypticServer",
        libraryTarget: 'umd'
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: "babel-loader"
                }
            }
        ]
    },
    watch: true,
    mode: "development",
    devtool: "cheap-eval-source-map"
}, {
    entry: './src/index.js',
    output: {
        filename: "main.min.js",
        library: "CrypticServer",
        libraryTarget: 'umd'
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: "babel-loader"
                }
            }
        ]
    },
    watch: true,
    mode: "production"
}];
