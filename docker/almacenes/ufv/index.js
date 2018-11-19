#!/usr/bin/env node

const fetch = require('fetch').fetchUrl,
cheerio = require('cheerio'),
moment = require('moment'),
Sequelize = require('sequelize'),
CronJob = require('cron').CronJob

moment.locale('es')

const sequelize = new Sequelize(process.env.MYSQL_DATABASE, process.env.MYSQL_USER, process.env.MYSQL_PASSWORD, {
  host: process.env.MYSQL_HOST,
  port: process.env.MYSQL_PORT,
  dialect: 'mysql',
  reconnect: {
    max_retries: 1,
    onRetry: (test) => {
      logger.info(`Conexión con base de datos perdida, intentando por ${test} vez`);
      process.exit(1);
    }
  }
})

const Ufv = sequelize.define('ufv', {
  fecha: Sequelize.DATE,
  valor: Sequelize.FLOAT
}, {
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  timestamps: true,
  underscored: true,
  indexes: [
    {
      unique: true,
      fields: ['fecha']
    }
  ]
})

new CronJob('0 0 6 * * *', () =>  {
  sequelize.authenticate()
  .then(() => {
    console.log(`Conectado a base de datos`)
    return sequelize.sync()
  })
  .then(() => {
    fetch('https://www.bcb.gob.bo/librerias/indicadores/ufv/ultimo.php', function(error, meta, body){
      const $ = cheerio.load(body.toString())
      const content = $('html').children('body').contents().text().split('\n')
      let date = content[5].trim().split('de')
      const day = Number(date[0])

      date = date[1].split(' ')
      const year = Number(date[2])
      const month = Number(moment().month(date[1]).format("M"))

      const value = content[8].split('por unidad de UFV')[0].split('Bs')[1].trim().replace(',', '.')

      return Ufv.create({
        fecha: `${year}-${month}-${day}`,
        valor: parseFloat(value)
      })
    })
  })
  .catch((error) => {
    console.error(`No se puede conectar con la base de datos`)
    process.exit(1)
  })
}, null, true, 'America/La_Paz')