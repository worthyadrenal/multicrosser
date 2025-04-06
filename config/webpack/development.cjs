process.env.NODE_ENV = process.env.NODE_ENV || 'development'

entry: './app/javascript/application.js',


const webpackConfig = require('./base.cjs')

module.exports = webpackConfig
