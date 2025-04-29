import fs from 'fs'

const data = JSON.parse(fs.readFileSync('NASDAQ.json', 'utf8'))
console.log(data.length)

let jArr = data
let res = Array.from(new Set(jArr.map(JSON.stringify))).map(JSON.parse)
console.log(res.length)

fs.writeFile('NASDAQ1.json', JSON.stringify(res, null, 2), (err) => {
  if (err) throw err
  console.log('JSON file saved!')
})
