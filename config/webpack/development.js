// config/webpack/development.js

process.env.NODE_ENV = process.env.NODE_ENV || 'development'


const environment = require('@rails/webpacker').environment


module.exports = environment.toWebpackConfig()

