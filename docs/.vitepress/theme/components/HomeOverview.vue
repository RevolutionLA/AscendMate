<template>
  <div class="ambient">
    <!-- ============ HERO ============ -->
    <section class="am-hero">
      <div class="am-hero-grid">
        <div class="am-lead">
          <span class="am-eyebrow">AscendMate</span>
          <h1 class="am-title">昇腾之家<br /><span class="acc">一站式部署与调优</span></h1>
          <p class="am-sub">面向昇腾智算服务器的实操手册，重点覆盖 <b>模型推理部署</b> 与 <b>性能调优</b>，并完整涵盖环境搭建、模型微调与算子开发，帮你快速落地、查得到、可照做。</p>
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
            <span class="u">Atlas 800I A3</span>
          </div>
          <div class="am-instrument-body">
            <div class="am-row"><span class="k">Driver Version</span><span class="v">25.1.0</span></div>
            <div class="am-row"><span class="k">CANN</span><span class="v">8.3.RC2</span></div>
            <div class="am-row"><span class="k">Health</span><span class="v g">Normal</span></div>
            <div class="am-row"><span class="k">HBM</span><span class="v">243.0 / 256.0 GB</span></div>
            <div class="am-row"><span class="k">HCCS Link</span><span class="v g">up · 8×C2C</span></div>
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

      <!-- ecosystem — uniform icon + label chips, all clickable -->
      <div class="ecosystem-strip">
        <span class="eco-label">Ecosystem</span>
        <a class="eco-chip" :href="b('/guide/ascend-landscape')"><img :src="b('/ascend/ascend-mark.svg')" alt="" /><span class="eco-t">Ascend</span></a>
        <a class="eco-chip" :href="b('/training/mindspeed')"><img :src="b('/ascend/mindspeed.svg')" alt="" /><span class="eco-t">MindSpeed</span></a>
        <a class="eco-chip" :href="b('/inference/mindie')"><img :src="b('/ascend/mindie.svg')" alt="" /><span class="eco-t">MindIE</span></a>
        <a class="eco-chip" :href="b('/setup/mindspore-install')"><img :src="b('/ascend/mindspore.svg')" alt="" /><span class="eco-t">MindSpore</span></a>
        <a class="eco-chip" :href="b('/training/llama-factory')"><img :src="b('/ascend/pytorch-official.svg')" alt="" /><span class="eco-t">PyTorch</span></a>
        <a class="eco-chip" :href="b('/inference/vllm-ascend')"><img :src="b('/ascend/vllm-official.png')" alt="" /><span class="eco-t">vLLM</span></a>
        <a class="eco-chip" :href="b('/inference/sglang')"><img :src="b('/ascend/sglang-official.svg')" alt="" /><span class="eco-t">SGLang</span></a>
        <a class="eco-chip" :href="b('/ops/triton-ascend')"><img :src="b('/ascend/triton.svg')" alt="" /><span class="eco-t">Triton</span></a>
      </div>
    </section>

    <!-- ============ SKILL HIGHLIGHT ============ -->
    <section class="am-section">
      <div class="am-skill-banner">
        <div class="am-skill-text">
          <span class="ey">亮点功能</span>
          <h2>Ascend Assistant · 昇腾服务器助手</h2>
          <p>让 AI 直接帮你检测环境、定位报错、生成命令、引导部署、给出调优建议。作为 Agent Skill 独立分发，与本手册深度联动。</p>
          <div class="am-skill-chips">
            <span class="am-tag">环境检测</span>
            <span class="am-tag">排障</span>
            <span class="am-tag">命令生成</span>
            <span class="am-tag">部署引导</span>
            <span class="am-tag">性能调优</span>
          </div>
          <div class="am-skill-actions">
            <a class="am-btn primary" :href="b('/skill/')">了解 & 安装 Skill →</a>
            <a class="am-btn ghost" href="https://github.com/RevolutionLA/ascend-assistant">访问独立仓库</a>
          </div>
        </div>
      </div>
    </section>

    <!-- ============ FEATURES ============ -->
    <section class="am-section">
      <div class="am-sec-head"><span class="ey">重点场景</span><h2>按部署目标快速切入</h2></div>
      <div class="am-feats">
        <a class="am-card hot" :href="b('/inference/')"><span class="num">01</span><h3>模型推理部署 🔥</h3><p>MindIE 服务化、vLLM-Ascend、SGLang、Dify 平台，接入 OpenAI 兼容服务，最快跑起推理。</p></a>
        <a class="am-card hot" :href="b('/tools/')"><span class="num">02</span><h3>工具链 · 性能调优</h3><p>MindStudio 开发调试、Profiling 性能分析、精度对齐，定位并解决性能瓶颈。</p></a>
        <a class="am-card" :href="b('/setup/')"><span class="num">03</span><h3>环境搭建</h3><p>操作系统 · 固件驱动 · CANN · torch_npu · MindSpore · Docker 离线。从裸机到可跑第一行代码的 7 步走。</p></a>
        <a class="am-card" :href="b('/training/')"><span class="num">04</span><h3>大模型训练</h3><p>LLaMA-Factory 微调、MindSpeed 预训练、PyTorch / MindSpore 模型迁移，含完整命令。</p></a>
        <a class="am-card" :href="b('/ops/')"><span class="num">05</span><h3>算子开发</h3><p>Ascend C、Triton-Ascend、CATLASS 自定义算子，GPU 算子迁移。</p></a>
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
            <tr><td>环境交付 / 运维</td><td>装系统、驱动、CANN 到可用环境</td><td><a class="am-pill" :href="b('/setup/')">环境搭建 <span class="am-pill-go">→</span></a></td></tr>
            <tr><td>算法 / 模型</td><td>微调、训练、部署推理</td><td>
              <a class="am-pill" :href="b('/training/llama-factory')">微调 <span class="am-pill-go">→</span></a>
              <a class="am-pill" :href="b('/inference/')">推理 <span class="am-pill-go">→</span></a>
            </td></tr>
            <tr><td>算子 / 移植</td><td>自定义算子、GPU 迁移</td><td>
              <a class="am-pill" :href="b('/ops/')">算子 <span class="am-pill-go">→</span></a>
              <a class="am-pill" :href="b('/training/pytorch-migration')">迁移 <span class="am-pill-go">→</span></a>
            </td></tr>
            <tr><td>应用 / 集成</td><td>推理服务、RAG 平台、业务接入</td><td>
              <a class="am-pill" :href="b('/inference/')">推理 <span class="am-pill-go">→</span></a>
              <a class="am-pill" :href="b('/inference/dify')">Dify <span class="am-pill-go">→</span></a>
            </td></tr>
            <tr><td>性能 / 调优</td><td>报错排查、性能、精度</td><td>
              <a class="am-pill" :href="b('/faq/')">问题 FAQ <span class="am-pill-go">→</span></a>
              <a class="am-pill" :href="b('/tools/')">工具链 <span class="am-pill-go">→</span></a>
            </td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ============ STEPS ============ -->
    <section class="am-section">
      <div class="am-sec-head"><span class="ey">如何开始</span><h2>三步上手</h2></div>
      <div class="am-steps">
        <div class="am-step"><span class="n">1</span><h3>选路径</h3><p>先确定你的场景。</p><a class="am-pill" :href="b('/guide/choose-your-path')">去路径选择 →</a></div>
        <div class="am-step"><span class="n">2</span><h3>做环境</h3><p>从裸机搭到可跑 PyTorch。</p><a class="am-pill" :href="b('/guide/seven-steps')">看 7 步走 →</a></div>
        <div class="am-step"><span class="n">3</span><h3>跑业务</h3><p>用现成方案跑起模型。</p>
          <a class="am-pill" :href="b('/training/')">去训练 →</a>
          <a class="am-pill" :href="b('/inference/')">去推理 →</a></div>
      </div>
    </section>
  </div>
</template>

<style scoped></style>

<script setup>
import { withBase } from 'vitepress'
const b = withBase
</script>
