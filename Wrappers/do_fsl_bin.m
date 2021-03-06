function fo = do_fsl_bin(f,par)
%function fo = do_fsl_bin(f,prefix,seuil)
%if seuil is a vector [min max] min<f<max
%if seuil is a number f>seuil


if ~exist('par'),par ='';end

defpar.fsl_output_format = 'NIFTI_GZ';
defpar.seuil = 0;
defpar.prefix = '';
defpar.bin = 1;
defpar.sge=0;
defpar.jobname = 'fslbin';
defpar.walltime = '00:10:00';

par = complet_struct(par,defpar);


  seuil=par.seuil;
  prefix=par.prefix;


f=cellstr(char(f));

fo = addprefixtofilenames(f,prefix);

for k=1:length(f)
  [pp ff] = fileparts(f{k});

  if length(seuil)==2
      cmd = sprintf('export FSLOUTPUTTYPE=%s;fslmaths %s -nan -thr %f -uthr %f ',par.fsl_output_format,f{k},seuil(1),seuil(2));  
  else
     cmd = sprintf('export FSLOUTPUTTYPE=%s;fslmaths %s -nan -thr %f ',par.fsl_output_format,f{k},seuil);
  end

  if par.bin
    cmd = sprintf('%s -bin -nan ',cmd);
  end
  
  cmd = sprintf('%s %s',cmd,fo{k});
  
   if par.sge
      job{k} = cmd;
  else
    unix(cmd);
  end

end

if par.sge
    do_cmd_sge(job,par)
end

