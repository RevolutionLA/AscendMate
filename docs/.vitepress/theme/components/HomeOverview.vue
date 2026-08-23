<template>
  <div class="ambient">
    <!-- ============ HERO ============ -->
    <section class="am-hero">
      <div class="am-hero-grid">
        <div class="am-lead">
          <span class="am-eyebrow">Ascend Deployment Handbook</span>
          <h1 class="am-title">昇腾部署<br /><span class="acc">易用一指禅</span></h1>
          <p class="am-sub">面向昇腾智算服务器的部署与开发手册。从环境搭建、模型微调、推理部署到算子开发，把散落各处的资料整理成可检索、可落地的实操入口。</p>
          <div class="am-actions">
            <a class="am-btn primary" :href="b('/guide/')">开始部署 <span aria-hidden="true">→</span></a>
            <a class="am-btn ghost" :href="b('/resources/')">资源导航</a>
            <a class="am-btn ghost" :href="b('/faq/')">问题定位</a>
          </div>
        </div>

        <!-- status instrument -->
        <div class="am-instrument" aria-label="npu-smi 状态示例">
          <div class="am-instrument-head">
            <span class="led"></span>
            <span class="tl">npu-smi</span>
            <span class="u">Atlas 800I A2</span>
          </div>
          <div class="am-instrument-body">
            <div class="am-row"><span class="k">Driver Version</span><span class="v">24.2.0</span></div>
            <div class="am-row"><span class="k">CANN</span><span class="v">8.5.0</span></div>
            <div class="am-row"><span class="k">Health</span><span class="v g">Normal</span></div>
            <div class="am-row"><span class="k">HBM</span><span class="v">62.4 / 64.0 GB</span></div>
            <div class="am-row"><span class="k">HCCS Link</span><span class="v g">up · 4×100G</span></div>
          </div>
          <div class="am-metric">
            <div class="mtop"><span>HBM Utilization</span><span>12%</span></div>
            <div class="am-meter"><span style="width:12%"></span></div>
          </div>
          <div class="am-instrument-foot">
            <span class="ok">● system healthy</span>
            <span class="am-cursor">_</span>
          </div>
        </div>
      </div>

      <!-- ecosystem — everything clickable -->
      <div class="ecosystem-strip">
        <span class="eco-label">Ecosystem</span>
        <a class="eco-item" :href="b('/guide/ascend-landscape')"><img :src="b('/ascend/ascend-logo.svg')" alt="Ascend" /></a>
        <a class="eco-item" :href="b('/training/mindspeed')"><img :src="b('/ascend/mindspeed.svg')" alt="MindSpeed" /></a>
        <a class="eco-item" :href="b('/inference/mindie')"><img :src="b('/ascend/mindie.svg')" alt="MindIE" /></a>
        <a class="eco-item" :href="b('/setup/mindspore-install')"><img :src="b('/ascend/mindspore.svg')" alt="MindSpore" /></a>
        <span class="eco-mono">
          <a :href="b('/training/llama-factory')">PyTorch</a> ·
          <a :href="b('/inference/vllm-ascend')">vLLM</a> ·
          <a :href="b('/inference/sglang')">SGLang</a> ·
          <a :href="b('/ops/triton-ascend')">Triton</a>
        </span>
      </div>
    </section>

    <!-- ============ FEATURES ============ -->
    <section class="am-section">
      <div class="am-sec-head"><span class="ey">本手册</span><h2>按部署目标快速切入</h2></div>
      <div class="am-feats">
        <a class="am-card" :href="b('/setup/')"><span class="num">01</span><h3>环境搭建</h3><p>操作系统 · 固件驱动 · CANN · torch_npu · MindSpore · Docker 离线。从裸机到可跑第一行代码的 7 步走。</p></a>
        <a class="am-card" :href="b('/training/')"><span class="num">02</span><h3>大模型训练</h3><p>LLaMA-Factory 微调、MindSpeed 预训练、PyTorch / MindSpore 模型迁移，含完整命令。</p></a>
        <a class="am-card" :href="b('/inference/')"><span class="num">03</span><h3>模型推理</h3><p>MindIE 服务化、vLLM-Ascend、SGLang、Dify 平台，接入 OpenAI 兼容服务。</p></a>
        <a class="am-card" :href="b('/ops/')"><span class="num">04</span><h3>算子开发</h3><p>Ascend C、Triton-Ascend、CATLASS 自定义算子，GPU 算子迁移。</p></a>
        <a class="am-card" :href="b('/tools/')"><span class="num">05</span><h3>工具链</h3><p>MindStudio 开发调试、精度对齐、Profiling 性能调优。</p></a>
        <a class="am-card" :href="b('/resources/')"><span class="num">06</span><h3>资源导航</h3><p>完整链接总表、软件/模型下载、生态与社区入口。</p></a>
      </div>
    </section>

    <!-- ============ WHO ============ -->
    <section class="am-section">
      <div class="am-sec-head"><span class="ey">适用岗位</span><h2>为谁而写</h2></div>
      <div class="am-table-wrap">
        <table class="am-who">
          <thead><tr><th>岗位</th><th>关注点</th><th>入口</th></tr></thead>
          <tbody>
            <tr><td>环境交付 / 运维</td><td>装系统、驱动、CANN 到可用环境</td><td><a :href="b('/setup/')">环境搭建</a></td></tr>
            <tr><td>算法 / 模型</td><td>微调、训练、部署推理</td><td><a :href="b('/training/llama-factory')">微调</a> · <a :href="b('/inference/')">推理</a></td></tr>
            <tr><td>算子 / 移植</td><td>自定义算子、GPU 迁移</td><td><a :href="b('/ops/')">算子</a> · <a :href="b('/training/pytorch-migration')">迁移</a></td></tr>
            <tr><td>应用 / 集成</td><td>推理服务、RAG 平台、业务接入</td><td><a :href="b('/inference/')">推理</a> · <a :href="b('/inference/dify')">Dify</a></td></tr>
            <tr><td>性能 / 调优</td><td>报错排查、性能、精度</td><td><a :href="b('/faq/')">FAQ</a> · <a :href="b('/tools/')">工具链</a></td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ============ STEPS ============ -->
    <section class="am-section">
      <div class="am-sec-head"><span class="ey">如何开始</span><h2>三步上手</h2></div>
      <div class="am-steps">
        <div class="am-step"><span class="n">1</span><h3>选路径</h3><p>在<a :href="b('/guide/choose-your-path')">路径选择</a>里找到你的场景。</p></div>
        <div class="am-step"><span class="n">2</span><h3>做环境</h3><p>按<a :href="b('/guide/seven-steps')">7 步走</a>从裸机到可跑 PyTorch。</p></div>
        <div class="am-step"><span class="n">3</span><h3>跑业务</h3><p>进入<a :href="b('/training/')">训练</a>或<a :href="b('/inference/')">推理</a>跑起模型。</p></div>
      </div>
    </section>
  </div>
</template>

<style scoped></style>

<script setup>
import { withBase } from 'vitepress'
const b = withBase
</script>
