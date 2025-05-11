<script setup>
import 'vue3-toastify/dist/index.css'
import { toast } from 'vue3-toastify'
import { useSelectedTextStore } from '@/stores/selectedSymbol'
import axios from 'axios'
import { storeToRefs } from 'pinia'
import { ref, watch } from 'vue'
import PulseLoader from 'vue-spinner/src/PulseLoader.vue'

const notify = (type, msg) => {
  toast(msg, {
    type: type,
    autoClose: 3000,
  }) // ToastOptions
}

const selectedTextStore = useSelectedTextStore()
const { selectedText } = storeToRefs(selectedTextStore)

const hasData = ref(false)
//+ Select Timeframe
const selected = ref('INTRADAY')
const options = ref(['INTRADAY', 'DAILY', 'WEEKLY', 'MONTHLY'])
//-

const isLoading = ref(false)
const meta_data = ref()

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

const fetchData = async (query) => {
  // console.log('xxx', query)
  const id = query.id
  const timeframe = query.timeframe
  console.log(id, ' === ', timeframe)
  try {
    isLoading.value = true
    // const response = await axios.get(`http://localhost:8000/stocks`)
    const response = await axios.get(`http://localhost:8000/stocks`, {
      params: query,
    })

    meta_data.value = Object.values(response.data)[0]
    console.log(Object.values(response.data)[0])
    console.log(Object.keys(meta_data.value)[0])

    if (Object.keys(meta_data.value)[0] == '1. Information') {
      notify('success', 'Fetching Stocks Data Successful!')
      hasData.value = true

      console.log(meta_data.value)
      console.log(meta_data.value['1. Information'])

      //const ts = response.data['Time Series (5min)']
      const timeseries = Object.values(response.data)[1]
      const ts = timeseries

      // sort datetimes ascending
      const times = Object.keys(ts).sort()
      const closes = times.map((t) => parseFloat(ts[t]['4. close']))

      option.value.title = {
        text: `${Object.values(meta_data.value)[1]}: ${Object.values(meta_data.value)[0]} (Closing Price)`,
        left: 'center',
      }
      option.value.xAxis.data = times
      option.value.series[0].data = closes
    } else {
      notify('warning', 'Failed Fetching Stocks Data!')
      hasData.value = false
    }
  } catch (err) {
    notify('error', 'Error Fetching Stocks Data!')
    console.error('Error Fetching Stocks Data', err)
  } finally {
    isLoading.value = false
  }
}

watch([selectedText, selected], ([newVar1, newVar2], [oldVar1, oldVar2]) => {
  if (newVar1 || newVar2) {
    fetchData({ id: newVar1, timeframe: newVar2 })
  }
})
</script>

<template>
  <main class="p-4 flex-1 overflow-y-auto">
    <div>
      <div class="bg-blue-200 p-3 rounded-2xl mb-3">
        <div class="flex flex-wrap space-x-2 mx-auto">
          <button
            v-for="option in options"
            :key="option"
            @click="selected = option"
            :class="selected === option ? 'bg-blue-500 text-white' : 'bg-gray-200 text-black'"
            class="px-4 py-2 rounded-md transition hover:cursor-pointer"
          >
            {{ option }}
          </button>
        </div>
      </div>
      <div class="bg-green-200 p-3 rounded-2xl">
        <div class="bg-white shadow-lg rounded-lg overflow-hidden border border-gray-300 p-2">
          <div v-if="hasData">
            <h2 class="font-bold text-gray-800">Stock Information</h2>
            <ul>
              <li v-for="(value, key) in meta_data" :key="key" class="text-gray-600">
                <strong>{{ key }}:</strong> {{ value }}
              </li>
            </ul>
          </div>
          <div v-else>
            <h2 class="font-bold text-gray-800">{{ meta_data }}</h2>
          </div>
        </div>
      </div>
    </div>

    <div>
      <hr class="border-t border-gray-300 my-4" />
    </div>
    <PulseLoader v-if="isLoading" class="float-left" />
    <div v-if="hasData" class="w-full">
      <v-chart :option="option" autoresize style="height: 400px; width: 80vw" />
    </div>
  </main>
</template>
