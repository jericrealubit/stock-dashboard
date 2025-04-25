<script setup>
import { useSelectedTextStore } from '@/stores/selectedSymbol'
import axios from 'axios'
import { storeToRefs } from 'pinia'
import { ref, watch } from 'vue'

const selectedTextStore = useSelectedTextStore()
const { selectedText } = storeToRefs(selectedTextStore)

const meta_data = ref([])

const option = ref({
  title: { text: '', left: 'center' },
  tooltip: { trigger: 'axis' },
  xAxis: { type: 'category', data: [] },
  yAxis: { type: 'value', scale: true },
  series: [
    {
      name: 'Close',
      type: 'line',
      data: [],
      smooth: true,
      lineStyle: { width: 2 },
    },
  ],
  dataZoom: [
    { type: 'inside', start: 20, end: 100 },
    { show: true, type: 'slider', top: '90%', start: 20, end: 100 },
  ],
})

const fetchData = async (text) => {
  try {
    // const response = await axios.get(`http://localhost:8000/stocks/${text}`)
    const response = await axios.get(`http://localhost:8000/stocks`)

    meta_data.value = response.data[0]['Meta Data']
    console.log(meta_data.value)
    console.log(meta_data.value['1. Information'])
    const ts = response.data[0]['Time Series (5min)']
    // sort datetimes ascending
    const times = Object.keys(ts).sort()
    const closes = times.map((t) => parseFloat(ts[t]['4. close']))

    option.value.title = {
      text: `${meta_data.value['2. Symbol']} 5-Min Close Price`,
      left: 'center',
    }
    option.value.xAxis.data = times
    option.value.series[0].data = closes
  } catch (err) {
    console.error('Error Fetching Stocks Data', err)
  }
}

watch(selectedText, (newText) => {
  if (newText) {
    fetchData(newText)
  }
})
</script>

<template>
  <main class="p-4 flex-1 overflow-y-auto">
    <h2 class="text-lg font-bold mb-4">Stock Informations</h2>
    <p>Clicked Text: {{ selectedTextStore.selectedText }}</p>
    <!-- 
    <div>{{ meta_data.value['1. Information'] }}</div>
    <div>{{ meta_data.value['2. Symbol'] }}</div>
    <div>{{ meta_data.value['3. Last Refreshed'] }}</div>
    <div>{{ meta_data.value['4. Interval'] }}</div>
    <div>{{ meta_data.value['5. Output Size'] }}</div>
    <div>{{ meta_data.value['6. Time Zone'] }}</div> -->

    <div class="w-full max-w-3xl mx-auto">
      <v-chart :option="option" autoresize style="height: 400px" />
    </div>
  </main>
</template>
