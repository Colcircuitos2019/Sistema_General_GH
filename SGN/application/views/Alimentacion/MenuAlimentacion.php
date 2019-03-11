   <!-- Menu lateral izquierdo de la pantalla -->
  <aside class="main-sidebar">
    <!-- sidebar: style can be found in sidebar.less -->
    <section class="sidebar">
      <!-- Sidebar user panel -->
      <div class="user-panel">
        <div class="pull-left image">
          <img src="<?php echo base_url();?>img/Logo.jpg" class="img-circle" alt="User Image">
        </div>
        <div class="pull-left info">
          <p>Administrador</p>
          <a href="#"><i class="fa fa-circle text-success"></i> Online</a>
        </div>
      </div>
      <!-- sidebar menu: : style can be found in sidebar.less -->
      <ul class="sidebar-menu" data-widget="tree">
        <li class="header">MENU DE NAVEGACIÓN</li>
        <!-- Boton desplegable 1 -->
        <li class="treeview">
          <a href="#">
            <i class="fas fa-utensils"></i>
            <span>Alimentacion</span>
            <span class="pull-right-container">
              <i class="fas fa-caret-left pull-right"></i>
            </span>
          </a>
          <ul class="treeview-menu">
            <li><a href="<?php echo base_url();?>Alimentacion/cAlimentacion/proveedor"><i class="far fa-circle"></i> Proveedores</a></li>
            <li><a href="<?php echo base_url();?>Alimentacion/cAlimentacion/Producto"><i class="far fa-circle"></i> Productos</a></li>
          </ul>
        </li>
        <!-- boton desplegable 2 -->
        <li class="treeview">
          <a href="#">
            <i class="fas fa-clipboard-list"></i> <span>Restricciones</span>
            <span class="pull-right-container">
              <i class="fas fa-caret-left pull-right"></i>
            </span>
          </a>
          <ul class="treeview-menu">
            <li><a href="<?php echo base_url();?>Alimentacion/cAlimentacion/configuracion"><i class="far fa-circle"></i> Configuración</a></li>
          </ul>
        </li>
        <!-- boton desplegable 3 -->
        <li class="treeview">
          <a href="#">
            <i class="fas fa-clipboard-list"></i> <span>Pedido</span>
            <span class="pull-right-container">
              <i class="fas fa-caret-left pull-right"></i>
            </span>
          </a>
          <ul class="treeview-menu">
            <li><a href="<?php echo base_url();?>Alimentacion/cPedidos/pedidos1"><i class="far fa-circle"></i> Pedidos</a></li>
          </ul>
        </li>
      </ul>
    </section>
    <!-- /.sidebar -->
  </aside>




          