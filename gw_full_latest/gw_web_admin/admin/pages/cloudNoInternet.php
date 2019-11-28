<!-- Tab panes -->
								
	<div class="tab-pane fade" id="cloudNoInternet-pills">
		</br>
		<div id="cloudNoInternet_status_msg"></div>
		
		<div class="col-md-10 col-md-offset-0">
		
			<p>
			<?php									
				ob_start();
				system("tac /home/pi/lora_gateway/log/post-processing.log | egrep -a -m 1 'uploading with python.*CloudNoInternet.*py' | cut -d '>' -f1"); 
				//system("egrep -a 'uploading with python.*CloudNoInternet.*py' /home/pi/lora_gateway/log/post-processing.log | tail -1 | cut -d '>' -f1");
				$last_upload=ob_get_contents(); 
				ob_clean();
				if ($last_upload=='') {
					echo '<font color="red"><b>no upload with CloudNoInternet.py found</b></font>';					
				}
				else {
					echo 'last upload time with CloudNoInternet.py: <font color="green"><b>';
					echo $last_upload;
					echo '</b></font>';					
				}									
			?>                            
			</p>
				
		  <div class="table-responsive">
			<table class="table table-striped table-bordered table-hover">
			  <thead></thead>
			 <tbody>
			   <tr>
				<td>Enabled</td>
				<td id="cloudNoInternet_status_value"><?php cloud_status($clouds, "python CloudNoInternet.py"); ?></td>
				<td align="right"><button id="btn_edit_cloudNoInternet_status" type="button" class="btn btn-primary"><span class="fa fa-edit"></span></button></td>
				<td id="td_edit_cloudNoInternet_status">
					<div id="div_cloudNoInternet_status_options" class="form-group">
						
						<div class="radio">
						<fieldset id="cloudNoInternet_status_group" >
							<label>
								<input type="radio" name="cloudNoInternet_status_group" id="cloudNoInternet_true" value="true" checked>True
							</label>
							</br>
							<label>
								<input type="radio" name="cloudNoInternet_status_group" id="cloudNoInternet_false" value="false" >False
							</label>
							</fieldset>
						</div>
					</div>
				</td> 
				<td id="td_cloudNoInternet_status_submit" align="right">
					<button id="btn_cloudNoInternet_status_submit" type="submit" class="btn btn-primary">Submit <span class="fa fa-arrow-right"></span></button>
				</td>
			   </tr>
			 </tbody>
			</table>
			<p>Cloud No Internet is used with WAZIUP cloud only.</pp>
		  </div>
		</div>
</div>		
